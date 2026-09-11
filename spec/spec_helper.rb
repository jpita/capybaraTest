# frozen_string_literal: true

require 'capybara/rspec'
require 'selenium-webdriver'

Dir[File.join(__dir__, 'support', '**', '*.rb')].sort.each { |f| require f }
require_relative 'pages/base_page'
Dir[File.join(__dir__, 'pages', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with(:rspec) { |e| e.include_chain_clauses_in_custom_matcher_descriptions = true }
  config.mock_with(:rspec) { |m| m.verify_partial_doubles = true }

  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  # Setup: start from the app's seeded data, with no account, order or challenge
  # left behind by an earlier run.
  config.before(:suite) do
    AppControl.restart
    BrowserState.clear
  end

  config.before(:each) { BrowserState.clear }

  # Teardown: drop the data this run created, and leave the app reseeded for
  # whoever uses it next.
  config.after(:suite) do
    BrowserState.clear
    AppControl.restart
  end

  config.include ApiClient
end
