require_relative 'boot'

require 'rails/all'
require 'rails_event_store'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CqrsEsSampleWithResNew
  class Application < Rails::Application
    Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.paths.add 'command/lib',          eager_load: true
    config.paths.add 'orders/lib',           eager_load: true
    config.paths.add 'payments/lib',         eager_load: true
    config.paths.add 'discounts/lib',        eager_load: true

    config.event_store = RailsEventStore::Client.new

    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.test_framework :rspec
    end
  end
end
