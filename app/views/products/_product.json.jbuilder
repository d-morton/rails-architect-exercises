json.extract! product, :id, :name, :net_price, :vat_rate, :created_at, :updated_at
json.url product_url(product, format: :json)