module OrderList
  class OrderPaidHandler
    def call(ev)
      order = Order.find_by(number: ev.data[:order_number])
      order.state = 'paid'
      order.save!
    end
  end
end
