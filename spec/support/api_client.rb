# frozen_string_literal: true

require 'json'
require 'net/http'
require 'securerandom'

# Test data is created over HTTP, not by clicking through the sign-up form.
# Only the behaviour under test goes through the browser.
module ApiClient
  Account = Struct.new(:email, :password, keyword_init: true)

  # Mother's maiden name, the question the register form defaults to.
  SECURITY_QUESTION_ID = 2

  # Registration is two calls in this app: the account, then the security answer that
  # links the account to its question. Without the second call the forgot-password
  # lookup answers {} and the answer field never enables.
  #
  # A parallel run has one app process on one SQLite file, so a concurrent write can
  # come back as a 500. Each attempt builds a fresh email, so a retry cannot collide
  # with the account the failed attempt may already have created.
  def register_account(attempts: 3)
    try = 0
    begin
      try += 1
      create_account
    rescue RuntimeError => e
      retry if try < attempts && e.message.match?(/returned 5\d\d/)

      raise
    end
  end

  private

  def create_account
    email = "capybara-#{SecureRandom.hex(6)}@example.test"
    password = 'Passw0rd!23'
    answer = SecureRandom.hex(4)

    created = post('/api/Users/',
                   email: email,
                   password: password,
                   passwordRepeat: password,
                   securityQuestion: { id: SECURITY_QUESTION_ID, question: "Mother's maiden name?",
                                       createdAt: '', updatedAt: '' },
                   securityAnswer: answer)

    post('/api/SecurityAnswers/',
         UserId: created.dig('data', 'id'),
         answer: answer,
         SecurityQuestionId: SECURITY_QUESTION_ID)

    Account.new(email: email, password: password)
  end

  def first_product_name
    get('/api/Products').dig('data', 0, 'name')
  end

  # The search page renders /rest/products/search in its own order, 15 per page,
  # so names from /api/Products can point at a product that is on a later page.
  def product_names(limit: 3)
    get('/rest/products/search?q=')['data'].first(limit).map { |product| product['name'] }
  end

  def total_product_count = get('/api/Products')['data'].size

  # A browser session is only signed in once the token is in local storage,
  # so the UI has to be loaded before it can be planted.
  # The basket id is read from session storage on every basket request, so
  # planting only the token sends those requests to /rest/basket/0.
  def sign_in_as(account)
    authentication = post('/rest/user/login', email: account.email, password: account.password)['authentication']
    token = authentication['token']
    visit('/')
    page.execute_script("localStorage.setItem('token', arguments[0])", token)
    page.execute_script("sessionStorage.setItem('bid', arguments[0])", authentication['bid'].to_s)
    page.driver.browser.manage.add_cookie(name: 'token', value: token)
    token
  end

  # The checkout cannot proceed without a payment method, and a fresh account has
  # none, so one is created the same way the account is: over HTTP, rather than by
  # driving a form that is not under test. The card model accepts expYear 2080-2099.
  def add_payment_method(token)
    post_authenticated('/api/Cards', token,
                       cardNum: 4_111_111_111_111_111, fullName: 'Test Person',
                       expMonth: 1, expYear: 2099)
  end

  private

  def base_uri = URI(ENV.fetch('TARGET_URL', 'http://localhost:3000'))

  def post(path, **body)
    request = Net::HTTP::Post.new(path, 'Content-Type' => 'application/json')
    request.body = body.to_json
    send_request(request)
  end

  def post_authenticated(path, token, **body)
    request = Net::HTTP::Post.new(path, 'Content-Type' => 'application/json',
                                        'Authorization' => "Bearer #{token}")
    request.body = body.to_json
    send_request(request)
  end

  def get(path) = send_request(Net::HTTP::Get.new(path))

  def send_request(request)
    response = Net::HTTP.start(base_uri.host, base_uri.port) { |http| http.request(request) }
    raise "#{request.method} #{request.path} returned #{response.code}" unless response.code.start_with?('2')

    JSON.parse(response.body)
  end
end
