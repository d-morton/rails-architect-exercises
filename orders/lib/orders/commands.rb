module Orders
  class SubmitOrderCommand
    include Command

    attribute :order_number,             String
    attribute :customer_id,              Integer

    validates_presence_of :order_number, :customer_id
  end

  class ExpireOrderCommand
    include Command

    attribute :order_number,             String

    validates_presence_of :order_number
  end

  class CalcelOrderCommand
    include Command

    attribute :order_number,             String

    validates_presence_of :order_number
  end

  class ShipOrderCommand
    include Command

    attribute :order_number,             String

    validates_presence_of :order_number
  end
end
