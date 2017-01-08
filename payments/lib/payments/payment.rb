require 'aggregate_root'

module Payments
  class Payment
    include AggregateRoot
    NotAuthorized                     = Class.new(StandardError)
    InvalidOperation                  = Class.new(StandardError)

    def initialize(payment_gateway:)
      @payment_gateway = payment_gateway
    end

    def authorize(order_number:, total_amount:, card_number:)
      raise InvalidOperation if authorized?
      raise InvalidOperation if captured? || released?
      begin
        transaction_identifier = payment_gateway.authorize(total_amount, card_number)
        apply(PaymentAuthorized.strict(data: {
          order_number: order_number,
          transaction_identifier: transaction_identifier}))
      rescue
        apply(PaymentAuthorizationFailed.new(data: {
          order_number: order_number}))
      end
    end

    def capture
      raise NotAuthorized unless authorized?
      raise InvalidOperation if captured? || released?
      payment_gateway.capture(transaction_identifier)
      apply(PaymentCaptured.strict(data: {
        order_number: order_number,
        transaction_identifier: transaction_identifier}))
    end

    def release
      raise NotAuthorized unless authorized?
      raise InvalidOperation if released?
      payment_gateway.release(transaction_identifier)
      apply(PaymentReleased.strict(data: {
        order_number: order_number,
        transaction_identifier: transaction_identifier}))
    end

    attr_reader :transaction_identifier
    private
    attr_reader :payment_gateway, :order_number, :authorized, :captured, :released

    def authorized?
      authorized
    end

    def captured?
      captured
    end

    def released?
      released
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
      @transaction_identifier = ev.data[:transaction_identifier]
    end

    def apply_authorize_failed(ev)
      @order_number = ev.data[:order_number]
    end

    def apply_captured(ev)
      @captured = true
    end

    def apply_released(ev)
      @released = true
    end
  end
end
