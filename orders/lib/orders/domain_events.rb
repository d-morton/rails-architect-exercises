require 'ruby_event_store'

module Orders
  OrderItemAdded = Class.new(RubyEventStore::Event)
  OrderSubmitted = Class.new(RubyEventStore::Event)

  class OrderExpired < RubyEventStore::Event
    SCHEMA = {
      order_number: String,
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end

  class OrderCancelled < RubyEventStore::Event
    SCHEMA = {
      order_number: String,
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end

  class OrderShipped < Class.new(RubyEventStore::Event)
    SCHEMA = {
      order_number: String,
      customer_id:  Integer,
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end

end