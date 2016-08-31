require 'command/bus'

module Orders
  class Service
    def initialize(store:, fee_calculator: FeeCalculator.new)
      @store          = store
      @fee_calculator = fee_calculator
      @bus            = Command::Bus.new.tap do |b|
        b.register(Orders::SubmitOrderCommand, method(:submit))
        b.register(Orders::ExpireOrderCommand, method(:expire))
        b.register(Orders::CancelOrderCommand, method(:cancel))
        b.register(Orders::ShipOrderCommand,   method(:ship))
      end
    end

    def call(*commands)
      ActiveRecord::Base.transaction do
        bus.dispatch(*commands)
      end
    end

    private

    def with_order(number)
      repository = AggregateRoot::Repository.new(@store)
      order = Order.new(number: number, fee_calculator: @fee_calculator)
      repository.load(order)
      yield order
      repository.store(order)
    end

    def submit(cmd)
      with_order(cmd.order_number) do |order|
        cmd.items.each do |item|
          order.add_item(sku:       item[:sku],
                         quantity:  item[:quantity],
                         net_price: item[:net_price],
                         vat_rate:  item[:vat_rate])
        end
        order.submit(customer_id: cmd.customer_id)
      end
    end

    def expire(cmd)
      with_order(cmd.order_number) do |order|
        order.expire
      end
    end

    def cancel(cmd)
      with_order(cmd.order_number) do |order|
        order.cancel
      end
    end

    def ship(cmd)
      with_order(cmd.order_number) do |order|
        order.ship
      end
    end
  end
end
