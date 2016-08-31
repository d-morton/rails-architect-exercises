module Orders
  class SubmitOrderCommand
    include Command

    attr_accessor :order_number
    attr_accessor :customer_id
    attr_accessor :items

    validates_presence_of :order_number, :customer_id, :items
    validates :customer_id, numericality: { only_integer: true }
  end

  class ExpireOrderCommand
    include Command

    attr_accessor :order_number

    validates_presence_of :order_number
  end

  class CancelOrderCommand
    include Command

    attr_accessor :order_number

    validates_presence_of :order_number
  end

  class ShipOrderCommand
    include Command

    attr_accessor :order_number

    validates_presence_of :order_number
  end
end
