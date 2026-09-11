# frozen_string_literal: true

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--window-size=1400,1000')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  # Without these, a token left in storage by one example signs the next one in.
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options,
                                      clear_local_storage: true,
                                      clear_session_storage: true)
end

Capybara.configure do |config|
  config.default_driver = ENV.fetch('HEADED', nil) ? :selenium_chrome : :headless_chrome
  config.app_host = ENV.fetch('TARGET_URL', 'http://localhost:3000')
  config.run_server = false

  # Every matcher retries until this deadline, so the suite needs no sleeps.
  config.default_max_wait_time = 10

  # Lets `click_button 'Close Welcome Banner'` match the button by its aria-label.
  config.enable_aria_label = true

  config.save_path = File.expand_path('../../screenshots', __dir__)
end
