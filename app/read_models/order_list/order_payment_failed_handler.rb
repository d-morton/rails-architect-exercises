module OrderList
  class OrderPaymentFailedHandler
    def call(ev)
      order = Order.find_by(number: ev.data[:order_number])
      order.state = 'payment failed'
      order.save!
    end
  end
end
