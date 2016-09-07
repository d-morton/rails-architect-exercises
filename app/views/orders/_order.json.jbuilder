json.extract! order, :id, :number, :items_count, :net_value, :vat_amount, :gross_value, :customer_name, :state, :created_at, :updated_at
json.url order_url(order, format: :json)