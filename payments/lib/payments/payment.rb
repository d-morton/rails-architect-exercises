require 'aggregate_root'

module Payments
  class Payment
    include AggregateRoot::Base
    NotAuthorized                     = Class.new(StandardError)
    InvalidOperation                  = Class.new(StandardError)

    def initialize(transaction_identifier:, payment_gateway:)
      self.id           = transaction_identifier
      @payment_gateway  = payment_gateway
    end

    def authorize(order_number:, total_amount:, card_number:)
      raise InvalidOperation if self.id
      raise InvalidOperation if captured? || released?
      begin
        transaction_identifier = @payment_gateway.authorize(total_amount, card_number)
        apply(PaymentAuthorized.new(data: {
          order_number: order_number,
          transaction_identifier: transaction_identifier}))
      rescue
        apply(PaymentAuthorizationFailed.new(data: {
          order_number: order_number}))
      end
    end

    def capture
      raise NotAuthorized unless self.id
      raise InvalidOperation if captured? || released?
      @payment_gateway.capture(self.id)
      apply(PaymentCaptured.new(data: {
        order_number: @order_number,
        transaction_identifier: self.id}))
    end

    def release
      raise NotAuthorized unless self.id
      raise InvalidOperation if released?
      @payment_gateway.release(self.id)
      apply(PaymentReleased.new(data: {
        order_number: @order_number,
        transaction_identifier: self.id}))
    end

    private
    def captured?
      @captured
    end

    def released?
      @released
    end

    def apply_strategy
      ->(aggregate, event) {
        {
          Payments::PaymentAuthorized => aggregate.method(:apply_authorized),
          Payments::PaymentAuthorizationFailed => aggregate.method(:apply_authorize_failed),
          Payments::PaymentCaptured => aggregate.method(:apply_captured),
          Payments::PaymentReleased => aggregate.method(:apply_released),
        }.fetch(event.class).call(event)
      }
    end

    def apply_authorized(ev)
      @authorized = true
      @order_number = ev.data[:order_number]
      self.id = ev.data[:transaction_identifier]
    end

    def apply_authorize_failed(ev)
      @order_number = ev.data[:order_number]
      self.id = 'failed-transactions'
    end

    def apply_captured(ev)
      @captured = true
    end

    def apply_released(ev)
      @released = true
    end
  end
end
