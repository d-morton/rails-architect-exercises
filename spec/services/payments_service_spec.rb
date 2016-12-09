require_relative '../spec_helper'

class TestPaymentGateway
  AuthorizationFailed = Class.new(StandardError)
  NotAuthorized       = Class.new(StandardError)

  def initialize
    @authorized = []
  end

  def authorize(total_amount, card_number)
    card_valid = card_number == '4242424242424242'
    raise AuthorizationFailed unless card_valid
    SecureRandom.hex(16)
  end

  def capture(transaction_identifier)
    raise NotAuthorized unless @authorized.include?(transaction_identifier)
  end

  def release(transaction_identifier)
    raise NotAuthorized unless @authorized.include?(transaction_identifier)
  end
end

RSpec.describe PaymentsService do
  let(:number_generator) { ->{ '12345' } }
  let(:pricing) { ->(_){ {net_price: 100.0, vat_rate: 0.23} } }

  it 'successful flow' do
    orders_service = OrdersService.new(store: Rails.application.config.event_store,
      pricing: pricing, number_generator: number_generator)
    payments_service = PaymentsService.new(store: Rails.application.config.event_store,
                                           payment_gateway: TestPaymentGateway.new)
    customer = Orders::Customer.create!(name: 'John')
    orders_service.call(
      Orders::SubmitOrderCommand.new(
        customer_id:  customer.id,
        items:        [
          { sku:        123,
            quantity:   2 }])
    )

    expect do
      payments_service.call(
        Payments::AuthorizePaymentCommand.new(
          order_number: '12345',
          total_amount: 281.0,
          card_number:  '4242424242424242')
      )
    end.not_to change { OrderList::Order.count }
    expect(OrderList::Order.find_by(number: '12345').state).to eq('paid')
  end

  it 'unsuccessful payment flow' do
    orders_service = OrdersService.new(store: Rails.application.config.event_store,
      pricing: pricing, number_generator: number_generator)
    payments_service = PaymentsService.new(store: Rails.application.config.event_store,
                                           payment_gateway: TestPaymentGateway.new)
    customer = Orders::Customer.create!(name: 'John')
    orders_service.call(
      Orders::SubmitOrderCommand.new(
        customer_id:  customer.id,
        items:        [
          { sku:        123,
            quantity:   2 }])
    )

    expect do
      payments_service.call(
        Payments::AuthorizePaymentCommand.new(
          order_number: '12345',
          total_amount: 281.0,
          card_number:  'invalid card number')
      )
    end.not_to change { OrderList::Order.count }
    expect(OrderList::Order.find_by(number: '12345').state).to eq('payment failed')
  end
end
