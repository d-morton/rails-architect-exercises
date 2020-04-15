require 'arkency/command_bus'

class OrdersService
  def initialize(store:, pricing:,
                 number_generator: Orders::NumberGenerator.new,
                 fee_calculator: Orders::FeeCalculator.new)
    @repository       = AggregateRoot::Repository.new(store)
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
      order.add_item(**item.merge(@pricing.call(item.fetch(:sku))))
    end
    order.submit(customer_id: cmd.customer_id)
    @repository.store(order, stream)
  end

  def expire(cmd)
    @repository.with_aggregate(
      Orders::Order.new(number: cmd.order_number, fee_calculator: @fee_calculator),
      "Order$#{cmd.order_number}"
    ) do |order|
      order.expire
    end
  end

  def cancel(cmd)
    @repository.with_aggregate(
      Orders::Order.new(number: cmd.order_number, fee_calculator: @fee_calculator),
      "Order$#{cmd.order_number}"
    ) do |order|
      order.cancel
    end
  end

  def ship(cmd)
    @repository.with_aggregate(
      Orders::Order.new(number: cmd.order_number, fee_calculator: @fee_calculator),
      "Order$#{cmd.order_number}"
    ) do |order|
      order.ship
    end
  end
end
