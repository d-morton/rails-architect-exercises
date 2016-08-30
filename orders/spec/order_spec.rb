require_relative 'spec_helper'

module Orders
  RSpec.describe Order do
    it 'order number is an aggregate id' do
      order = Order.new(number: '12345')
      expect(order.id).to eq('12345')
    end

    it 'newly created order could be cancelled' do
      order = Order.new(number: '12345')
      expect{ order.cancel }.not_to raise_error
      expect(order).to publish [
        OrderCancelled.new(data: { order_number: '12345' }),
      ]
    end

    it 'newly created order could be expired' do
      order = Order.new(number: '12345')
      expect{ order.expire }.not_to raise_error
      expect(order).to publish [
        OrderExpired.new(data: { order_number: '12345' }),
      ]
    end

    it 'newly created order could not be shipped' do
      order = Order.new(number: '12345')
      expect{ order.ship }.to raise_error(Order::NotAllowed)
    end

    it 'cancelled order could not be modified, submitted or shipped' do
      order = Order.new(number: '12345')
      order.cancel
      expect{ order.add_item(sku: 123, quantity: 1, net_price: 100.0, vat_rate: 0.23)}.to raise_error(Order::NotAllowed)
      expect{ order.submit(customer_id: 123)}.to raise_error(Order::NotAllowed)
      expect{ order.ship }.to raise_error(Order::NotAllowed)
    end

    it 'expired order could not be modified, submitted or shipped' do
      order = Order.new(number: '12345')
      order.expire
      expect{ order.add_item(sku: 123, quantity: 1, net_price: 100.0, vat_rate: 0.23)}.to raise_error(Order::NotAllowed)
      expect{ order.submit(customer_id: 123)}.to raise_error(Order::NotAllowed)
      expect{ order.ship }.to raise_error(Order::NotAllowed)
    end

    it 'empty order could not be submitted' do
      order = Order.new(number: '12345')
      expect{ order.submit(customer_id: 123)}.to raise_error(Order::Invalid)
    end

    it 'item could be added to draft order' do
      order = Order.new(number: '12345')
      expect{ order.add_item(sku: 123, quantity: 1, net_price: 100.0, vat_rate: 0.23)}.not_to raise_error
      expect(order).to publish [
        OrderItemAdded.new(data: { order_number:  '12345',
                           sku:           123,
                           quantity:      1,
                           net_price:     100.0,
                           vat_rate:      0.23 }),
      ]
    end

    it 'order with items could be submitted & shipped' do
      order = Order.new(number: '12345')
      order.add_item(sku: 123, quantity: 2, net_price: 100.0, vat_rate: 0.23)
      expect{ order.submit(customer_id: 123)}.not_to raise_error
      expect{ order.ship }.not_to raise_error
      expect(order).to publish [
        OrderItemAdded.new(data: { order_number:  '12345',
                           sku:           123,
                           quantity:      2,
                           net_price:     100.0,
                           vat_rate:      0.23 }),
        OrderSubmitted.new(data: { order_number:  '12345',
                           customer_id:   123,
                           items: [
                             { sku:       123,
                               quantity:  2,
                               net_price: 100.0,
                               vat_rate:  0.23 },
                           ],
                           net_total:     200.0,
                           fee:           15.0 }),
        OrderShipped.new(data: { order_number:    '12345' }),
      ]
    end

  end
end
