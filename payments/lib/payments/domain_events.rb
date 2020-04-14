require 'ruby_event_store'

module Payments
  class PaymentAuthorized < RubyEventStore::Event
    SCHEMA = {
      transaction_identifier: String,
      order_number:  String,
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end

  class PaymentAuthorizationFailed < RubyEventStore::Event
    SCHEMA = {
      order_number:  String,
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end

  class PaymentCaptured < RubyEventStore::Event
    SCHEMA = {
      transaction_identifier: String,
      order_number:  String,
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end

  class PaymentReleased < RubyEventStore::Event
    SCHEMA = {
      transaction_identifier: String,
      order_number:  String,
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
