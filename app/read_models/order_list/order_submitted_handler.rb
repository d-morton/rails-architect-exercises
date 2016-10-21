module OrderList
  class OrderSubmittedHandler
    def call(ev)
      customer = Orders::Customer.find(ev.data[:customer_id])
      Order.create!(
        number:         ev.data[:order_number],
        items_count:    ev.data[:items_count],
        net_value:      ev.data[:net_total],
        vat_amount:     ev.data[:vat_total],
        gross_value:    ev.data[:gross_total],
        customer_name:  customer.name,
        state:          'submitted')
    end
  end
end
