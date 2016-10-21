module OrderList
  class OrderCancelledHandler
    def call(ev)
      order = Order.find_by(number: ev.data[:order_number])
      order.state = 'cancelled'
      order.save!
    end
  end
end
