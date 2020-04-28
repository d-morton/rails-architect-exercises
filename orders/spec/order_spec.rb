module Orders
  RSpec.describe Order do
    it 'newly created order could be cancelled' do
      order = Order.new(number: '12345')
      expect{ order.cancel }.not_to raise_error
      expect(order).to have_applied(
        an_event(OrderCancelled).with_data(order_number: '12345').strict,
      )
    end

    it 'newly created order could be expired' do
      order = Order.new(number: '12345')
      expect{ order.expire }.not_to raise_error
      expect(order).to have_applied(
        an_event(OrderExpired).with_data(order_number: '12345').strict,
      )
    end

    it 'newly created order could not be shipped' do
      order = Order.new(number: '12345')
      expect{ order.ship }.to raise_error(Order::NotAllowed)
    end

    it 'cancelled order could not be modified, submitted or shipped' do
      order = Order.new(number: '12345')
      order.cancel
      expect{ order.add_item(sku: 123, quantity: 1, net_price: 100.0, vat_rate: 23)}.to raise_error(Order::NotAllowed)
      expect{ order.submit(customer_id: 123)}.to raise_error(Order::NotAllowed)
      expect{ order.ship }.to raise_error(Order::NotAllowed)
    end

    it 'expired order could not be modified, submitted or shipped' do
      order = Order.new(number: '12345')
      order.expire
      expect{ order.add_item(sku: 123, quantity: 1, net_price: 100.0, vat_rate: 23)}.to raise_error(Order::NotAllowed)
      expect{ order.submit(customer_id: 123)}.to raise_error(Order::NotAllowed)
      expect{ order.ship }.to raise_error(Order::NotAllowed)
    end

    it 'empty order could not be submitted' do
      order = Order.new(number: '12345')
      expect{ order.submit(customer_id: 123)}.to raise_error(Order::Invalid)
    end

    it 'item could be added to draft order' do
      order = Order.new(number: '12345')
      expect{ order.add_item(sku: 123, quantity: 1, net_price: 100.0, vat_rate: 23)}.not_to raise_error
      expect(order).to have_applied(
        an_event(OrderItemAdded).with_data(
          order_number:  '12345',
          sku:           123,
          quantity:      1,
          net_price:     100.0,
          net_value:     100.0,
          vat_amount:    23.0,
          gross_value:   123.0,
        ).strict,
      )
    end

    it 'order with items could be submitted & shipped' do
      order = Order.new(number: '12345')
      order.add_item(sku: 123, quantity: 2, net_price: 100.0, vat_rate: 23)
      expect{ order.submit(customer_id: 123)}.not_to raise_error
      expect{ order.ship }.not_to raise_error
      expect(order).to have_applied(
        an_event(OrderItemAdded).with_data(
          order_number:  '12345',
          sku:           123,
          quantity:      2,
          net_price:     100.0,
          net_value:     200.0,
          vat_amount:    46.0,
          gross_value:   246.0,
        ).strict,
       an_event(OrderSubmitted).with_data(
         order_number:  '12345',
         customer_id:   123,
         items_count:   2,
         net_total:     200.0,
         vat_total:     46.0,
         gross_total:   246.0,
         fee:           0.0,
        ).strict,
       an_event(OrderShipped).with_data(
         order_number:  '12345',
         customer_id:   123,
        ).strict
      )
    end

    it 'shipped order could not be cancelled' do
      order = Order.new(number: '12345')
      order.add_item(sku: 123, quantity: 2, net_price: 100.0, vat_rate: 23)
      order.submit(customer_id: 123)
      order.ship
      expect{ order.cancel }.to raise_error(Order::NotAllowed)
    end

    it 'shipped order won\'t expire' do
      order = Order.new(number: '12345')
      order.add_item(sku: 123, quantity: 2, net_price: 100.0, vat_rate: 23)
      order.submit(customer_id: 123)
      order.ship
      expect(order).not_to have_applied(
        an_event(OrderExpired).with_data(order_number: '12345').strict
      )
    end

    it 'expired order won\'t expire again' do
      order = Order.new(number: '12345')
      order.add_item(sku: 123, quantity: 2, net_price: 100.0, vat_rate: 23)
      order.submit(customer_id: 123)
      expect { order.expire }.to apply(an_event(OrderExpired)).in(order).strict
      expect { order.expire }.not_to apply(an_event(OrderExpired)).in(order)
    end

    it 'rejects negative vat rates' do
      order = Order.new(number: '12345')
      expect do
        order.add_item(sku: 123, quantity: 2, net_price: 100.0, vat_rate: -1)
      end.to raise_error(ArgumentError)
    end

    it 'rejects above 100 vat rates' do
      order = Order.new(number: '12345')
      expect do
        order.add_item(sku: 123, quantity: 2, net_price: 100.0, vat_rate: 101)
      end.to raise_error(ArgumentError)
    end
  end
end
