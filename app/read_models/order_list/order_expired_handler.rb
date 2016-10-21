module OrderList
  class OrderExpiredHandler
    def call(ev)
      order = Order.find_by(number: ev.data[:order_number])
      order.state = 'expired'
      order.save!
    end
  end
end
