module OrderList
  class OrderShippedHandler
    def call(ev)
      order = Order.find_by(number: ev.data[:order_number])
      order.state = 'delivered'
      order.save!
    end
  end
end
