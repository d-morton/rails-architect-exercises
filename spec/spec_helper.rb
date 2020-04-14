ENV['RAILS_ENV'] = 'test'

require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'rspec/collection_matchers'
require 'rspec/active_model/mocks'
require 'database_cleaner'

RSpec.configure do |config|
  config.include ::RailsEventStore::RSpec::Matchers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.disable_monkey_patching!
  config.order = :random
  config.formatter = :documentation

  Kernel.srand(config.seed)

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

RspecFriendlyRandom = Random.new(RSpec.configuration.seed)
