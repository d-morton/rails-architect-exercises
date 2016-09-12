require 'arkency/command_bus'

class OrdersService
  def initialize(store:, fee_calculator: Orders::FeeCalculator.new)
    @store          = store
    @fee_calculator = fee_calculator

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
    repository = AggregateRoot::Repository.new(@store)
    order = Orders::Order.new(number: number, fee_calculator: @fee_calculator)
    repository.load(order)
    yield order
    repository.store(order)
  end

  def submit(cmd)
    with_order(cmd.order_number) do |order|
      cmd.items.each do |item|
        order.add_item(item)
      end
      order.submit(customer_id: cmd.customer_id)
    end

    event = Orders::OrderExpirationScheduled.new(data: { order_number: cmd.order_number })
    @store.publish_event(event, stream_name: cmd.order_number)
    ExpireOrderHandler.set(wait: 15.minutes).perform_later(YAML.dump(event))
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
