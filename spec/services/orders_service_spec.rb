require_relative '../spec_helper'

RSpec.describe OrdersService do
  let(:number_generator) { ->{ '12345' } }
  let(:pricing) { ->(_){ {net_price: 100.0, vat_rate: 0.23} } }

  it 'successful order flow' do
    service = OrdersService.new(store: Rails.application.config.event_store,
      pricing: pricing, number_generator: number_generator)
    customer = Orders::Customer.create!(name: 'John')

    expect do
      service.call(
        Orders::SubmitOrderCommand.new(
          customer_id:  customer.id,
          items:        [
            { sku:        123,
              quantity:   2 }])
      )
    end.to change { OrderList::Order.count }.by(1)

    expect(OrderList::Order.find_by(number: '12345').state).to eq('submitted')

    expect do
      service.call(
        Orders::ShipOrderCommand.new(
          order_number: '12345')
      )
    end.not_to change { OrderList::Order.count }

    expect(OrderList::Order.find_by(number: '12345').state).to eq('delivered')
  end

  it 'expired order flow' do
    service = OrdersService.new(store: Rails.application.config.event_store,
      pricing: pricing, number_generator: number_generator)
    customer = Orders::Customer.create!(name: 'John')

    service.call(
      Orders::SubmitOrderCommand.new(
        customer_id:  customer.id,
        items:        [
          { sku:        123,
            quantity:   2 }]),
      Orders::ExpireOrderCommand.new(
        order_number: '12345'),
    )

    expect(OrderList::Order.find_by(number: '12345').state).to eq('expired')
  end

  it 'cancelled order flow' do
    service = OrdersService.new(store: Rails.application.config.event_store,
      pricing: pricing, number_generator: number_generator)
    customer = Orders::Customer.create!(name: 'John')

    service.call(
      Orders::SubmitOrderCommand.new(
        customer_id:  customer.id,
        items:        [
          { sku:        123,
            quantity:   2 }]),
      Orders::CancelOrderCommand.new(
        order_number: '12345'),
    )

    expect(OrderList::Order.find_by(number: '12345').state).to eq('cancelled')
  end

  it 'won\'t fail on expiring shipped order' do
    service = OrdersService.new(store: Rails.application.config.event_store,
      pricing: pricing, number_generator: number_generator)
    customer = Orders::Customer.create!(name: 'John')

    expect do
      service.call(
        Orders::SubmitOrderCommand.new(
          customer_id:  customer.id,
          items:        [
            { sku:        123,
              quantity:   2 }]),
        Orders::ShipOrderCommand.new(
          order_number: '12345'),
        Orders::ExpireOrderCommand.new(order_number: '12345')
      )
    end.not_to raise_error
  end
end
