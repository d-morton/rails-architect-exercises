require 'arkency/command_bus'

class OrdersService
  def initialize(store:, pricing:,
                 number_generator: Orders::NumberGenerator.new,
                 fee_calculator: Orders::FeeCalculator.new)
    @store            = store
    @pricing          = pricing
    @number_generator = number_generator
    @fee_calculator   = fee_calculator

    @command_bus    = Arkency::CommandBus.new
    { Orders::SubmitOrderCommand  => method(:submit),
      Orders::ExpireOrderCommand  => method(:expire),
      Orders::CancelOrderCommand  => method(:cancel),
      Orders::ShipOrderCommand    => method(:ship),
    }.map{|klass, handler| @command_bus.register(klass, handler)}
  end

  def call(*commands)
    commands.each do |cmd|
      @command_bus.call(cmd)
    end
  end

  private

  def with_order(number)
    stream = "Order$#{number}"
    order = Orders::Order.new(number: number, fee_calculator: @fee_calculator)
    order.load(stream, event_store: @store)
    yield order
    order.store(stream, event_store: @store)
  end

  def submit(cmd)
    order_number = @number_generator.call
    with_order(order_number) do |order|
      cmd.items.each do |item|
        order.add_item(item.merge(@pricing.call(item.fetch(:sku))))
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
