module Orders
  class SubmitOrderCommand
    include Command

    attr_reader :customer_id
    attr_accessor :items

    validates_presence_of :customer_id, :items

    def customer_id=(int)
      @customer_id = Integer(int)
    end
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
