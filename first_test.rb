require 'capybara/rspec'
require 'rspec/expectations'


include RSpec::Matchers

Capybara.run_server = false

Capybara.current_driver = :selenium
Capybara.app_host = 'http://www.google.com'
#visit('/')
#visit('http://www.facebook.com')


session = Capybara::Session.new(:selenium)
session.visit 'https://www.facebook.com/'
puts session.title
expect(session.title.include? "Facebook - Log In or Sin Up").to be true