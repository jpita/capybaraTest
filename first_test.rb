require 'capybara/rspec'
require 'rspec/expectations'


include RSpec::Matchers

Capybara.run_server = false
Capybara.current_driver = :selenium


driver = Capybara::Session.new(:selenium)
driver.visit 'https://www.facebook.com/'
puts driver.title
expect(driver.title.include? "Facebook - Log In or Sign Up").to be true
driver.click_button('Log In')
puts driver.title
expect(driver).to have_selector('.signup_btn')
