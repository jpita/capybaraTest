# frozen_string_literal: true

RSpec.feature 'Session', type: :feature do
  let(:account) { register_account }

  scenario 'logging out drops the session' do
    login = LoginPage.new.open.sign_in(email: account.email, password: account.password)
    expect(login).to be_signed_in

    login.log_out

    expect(LoginPage.new.open).not_to be_signed_in
  end

  scenario 'a logged out customer loses access to their addresses again' do
    LoginPage.new.open.sign_in(email: account.email, password: account.password).log_out

    expect(SavedAddressesPage.new.open).to be_login_required
  end

  scenario 'the session survives a page reload' do
    LoginPage.new.open.sign_in(email: account.email, password: account.password)

    visit('/#/search')

    expect(SearchPage.new).to be_signed_in
  end

  scenario 'signing in with remember me keeps the customer signed in' do
    login = LoginPage.new.open
    login.remember_me
    login.sign_in(email: account.email, password: account.password)

    expect(login).to be_signed_in
  end

  scenario 'the basket follows the customer across pages' do
    sign_in_as(account)
    SearchPage.new.open.add_first_to_basket

    expect(ContactPage.new.open.basket_count).to eq(1)
  end
end
