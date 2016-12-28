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

  def submit(cmd)
    order_number = @number_generator.call
    stream = "Order$#{order_number}"
    order = Orders::Order.new(number: order_number, fee_calculator: @fee_calculator)
    cmd.items.each do |item|
      order.add_item(item.merge(@pricing.call(item.fetch(:sku))))
    end
    order.submit(customer_id: cmd.customer_id)
    order.store(stream, event_store: @store)
  end

  def expire(cmd)
    stream = "Order$#{cmd.order_number}"
    order = Orders::Order.new(number: cmd.order_number, fee_calculator: @fee_calculator)
    order.load(stream, event_store: @store)
    order.expire
    order.store(stream, event_store: @store)
  end

  def cancel(cmd)
    stream = "Order$#{cmd.order_number}"
    order = Orders::Order.new(number: cmd.order_number, fee_calculator: @fee_calculator)
    order.load(stream, event_store: @store)
    order.cancel
    order.store(stream, event_store: @store)
  end

  def ship(cmd)
    stream = "Order$#{cmd.order_number}"
    order = Orders::Order.new(number: cmd.order_number, fee_calculator: @fee_calculator)
    order.load(stream, event_store: @store)
    order.ship
    order.store(stream, event_store: @store)
  end
end
