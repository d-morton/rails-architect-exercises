require_relative '../spec_helper'

RSpec.describe OrdersService do
  it 'successful order flow' do
    service = OrdersService.new(store: Rails.application.config.event_store)
    customer = Customer.create!(name: 'John')

    expect do
      service.call(
        Orders::SubmitOrderCommand.new(
          order_number: '12345',
          customer_id:  customer.id,
          items:        [
            { sku:        123,
              quantity:   2,
              net_price:  100.0,
              vat_rate:   0.23 }])
      )
    end.to change { Order.count }.by(1)

    expect(Order.find_by(number: '12345').state).to eq('submitted')

    expect do
      service.call(
        Orders::ShipOrderCommand.new(
          order_number: '12345')
      )
    end.not_to change { Order.count }

    expect(Order.find_by(number: '12345').state).to eq('delivered')
  end

  it 'schedules order expiration on order flow' do
    service = OrdersService.new(store: Rails.application.config.event_store)
    customer = Customer.create!(name: 'John')

    expect do
      service.call(
        Orders::SubmitOrderCommand.new(
          order_number: '12345',
          customer_id:  customer.id,
          items:        [
            { sku:        123,
              quantity:   2,
              net_price:  100.0,
              vat_rate:   0.23 }])
      )
    end.to have_enqueued_job(ExpireOrderHandler).with do |serialized_event|
      event = YAML.load(serialized_event)
      expect(event.data.order_number).to eq('12345')
      expect(event).to be_a(Orders::OrderExpirationScheduled)
    end
  end

  it 'expired order flow' do
    service = OrdersService.new(store: Rails.application.config.event_store)
    customer = Customer.create!(name: 'John')

    service.call(
      Orders::SubmitOrderCommand.new(
        order_number: '12345',
        customer_id:  customer.id,
        items:        [
          { sku:        123,
            quantity:   2,
            net_price:  100.0,
            vat_rate:   0.23 }]),
      Orders::ExpireOrderCommand.new(
        order_number: '12345'),
    )

    expect(Order.find_by(number: '12345').state).to eq('expired')
  end

  it 'cancelled order flow' do
    service = OrdersService.new(store: Rails.application.config.event_store)
    customer = Customer.create!(name: 'John')

    service.call(
      Orders::SubmitOrderCommand.new(
        order_number: '12345',
        customer_id:  customer.id,
        items:        [
          { sku:        123,
            quantity:   2,
            net_price:  100.0,
            vat_rate:   0.23 }]),
      Orders::CancelOrderCommand.new(
        order_number: '12345'),
    )

    expect(Order.find_by(number: '12345').state).to eq('cancelled')
  end

  it 'won\'t fail on expiring shipped order' do
    service = OrdersService.new(store: Rails.application.config.event_store)
    customer = Customer.create!(name: 'John')

    expect do
      service.call(
        Orders::SubmitOrderCommand.new(
          order_number: '12345',
          customer_id:  customer.id,
          items:        [
            { sku:        123,
              quantity:   2,
              net_price:  100.0,
              vat_rate:   0.23 }]),
        Orders::ShipOrderCommand.new(
          order_number: '12345'),
        Orders::ExpireOrderCommand.new(order_number: '12345')
      )
    end.not_to raise_error
  end
end
