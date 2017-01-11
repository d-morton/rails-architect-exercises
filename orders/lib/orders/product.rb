class Orders::Product < ApplicationRecord
  def sku
    id.to_s
  end
end