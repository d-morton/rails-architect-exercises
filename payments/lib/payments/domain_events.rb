require 'ruby_event_store'

module Payments
  PaymentAuthorized           = Class.new(RubyEventStore::Event)
  PaymentAuthorizationFailed  = Class.new(RubyEventStore::Event)
  PaymentCaptured             = Class.new(RubyEventStore::Event)
  PaymentReleased             = Class.new(RubyEventStore::Event)
end
