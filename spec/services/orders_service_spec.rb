require_relative '../spec_helper'

RSpec.describe OrdersService do
  let(:event_store) { RubyEventStore::Client.new(RubyEventStore::InMemoryRepository.new) }

  it 'successful order flow' do
    store = event_store
    service = OrdersService.new(store: store)
    service.call(
      Orders::SubmitOrderCommand.new(
        order_number: '12345',
        customer_id:  123,
        items:        [
          { sku:        123,
            quantity:   2,
            net_price:  100.0,
            vat_rate:   0.23 }]),
      Orders::ShipOrderCommand.new(
        order_number: '12345'),
    )

    stream = store.read_stream_events_forward('12345')
    expect(stream).to have_events [
      Orders::OrderItemAdded.new(data: { order_number:  '12345',
                         sku:           123,
                         quantity:      2,
                         net_price:     100.0,
                         vat_rate:      0.23 }),
      Orders::OrderSubmitted.new(data: { order_number:  '12345',
                         customer_id:   123,
                         items: [
                           { sku:       123,
                             quantity:  2,
                             net_price: 100.0,
                             vat_rate:  0.23 },
                         ],
                         net_total:     200.0,
                         fee:           15.0 }),
      Orders::OrderShipped.new(data: { order_number:    '12345' }),
    ]
  end

  it 'expired order flow' do
    store = event_store
    service = OrdersService.new(store: store)
    service.call(
      Orders::SubmitOrderCommand.new(
        order_number: '12345',
        customer_id:  123,
        items:        [
          { sku:        123,
            quantity:   2,
            net_price:  100.0,
            vat_rate:   0.23 }]),
      Orders::ExpireOrderCommand.new(
        order_number: '12345'),
    )

    stream = store.read_stream_events_forward('12345')
    expect(stream).to have_events [
      Orders::OrderItemAdded.new(data: { order_number:  '12345',
                         sku:           123,
                         quantity:      2,
                         net_price:     100.0,
                         vat_rate:      0.23 }),
      Orders::OrderSubmitted.new(data: { order_number:  '12345',
                         customer_id:   123,
                         items: [
                           { sku:       123,
                             quantity:  2,
                             net_price: 100.0,
                             vat_rate:  0.23 },
                         ],
                         net_total:     200.0,
                         fee:           15.0 }),
      Orders::OrderExpired.new(data: { order_number:    '12345' }),
    ]
  end

  it 'cancelled order flow' do
    store = event_store
    service = OrdersService.new(store: store)
    service.call(
      Orders::SubmitOrderCommand.new(
        order_number: '12345',
        customer_id:  123,
        items:        [
          { sku:        123,
            quantity:   2,
            net_price:  100.0,
            vat_rate:   0.23 }]),
      Orders::CancelOrderCommand.new(
        order_number: '12345'),
    )

    stream = store.read_stream_events_forward('12345')
    expect(stream).to have_events [
      Orders::OrderItemAdded.new(data: { order_number:  '12345',
                         sku:           123,
                         quantity:      2,
                         net_price:     100.0,
                         vat_rate:      0.23 }),
      Orders::OrderSubmitted.new(data: { order_number:  '12345',
                         customer_id:   123,
                         items: [
                           { sku:       123,
                             quantity:  2,
                             net_price: 100.0,
                             vat_rate:  0.23 },
                         ],
                         net_total:     200.0,
                         fee:           15.0 }),
      Orders::OrderCancelled.new(data: { order_number:    '12345' }),
    ]
  end
end
