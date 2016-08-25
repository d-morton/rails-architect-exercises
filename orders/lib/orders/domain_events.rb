require 'ruby_event_store'

module Orders
  OrderSubmitted  = Class.new(RubyEventStore::Event)
  OrderExpired    = Class.new(RubyEventStore::Event)
  OrderCancelled  = Class.new(RubyEventStore::Event)
  OrderShipped    = Class.new(RubyEventStore::Event)
end
