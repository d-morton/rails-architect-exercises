require_relative 'boot'

require 'rails/all'
require 'rails_event_store'
require_relative '../orders/lib/orders'
require_relative '../payments/lib/payments'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CqrsEsSampleWithResNew
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.paths.add 'orders/lib',           eager_load: true
    config.paths.add 'discounts/lib',        eager_load: true

    config.event_store = RailsEventStore::Client.new

    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.test_framework :rspec
    end
  end
end
