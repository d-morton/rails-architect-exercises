require 'ruby_event_store'

module Orders
  OrderItemAdded = Class.new(RubyEventStore::Event)
  OrderSubmitted = Class.new(RubyEventStore::Event)
  OrderExpired   = Class.new(RubyEventStore::Event)
  OrderCancelled = Class.new(RubyEventStore::Event)

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