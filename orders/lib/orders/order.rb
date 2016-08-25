require 'aggregate_root'

module Orders
  class Order
    include AggregateRoot::Base
    NotAllowed = Class.new(StandardError)
    Invalid    = Class.new(StandardError)

    def initialize(number:, fee_calculator: FeeCalculator.new)
      self.id         = number
      @state          = :draft
      @items          = []
      @fee_calculator = fee_calculator
    end

    def item(sku:, quantity:, net_price:, vat_rate:)
      raise NotAllowed unless @state == :draft
      apply(OrderItemAdded.new(
        order_number: number,
        sku: sku,
        quantity: quantity,
        net_price: net_price,
        vat_rate: vat_rate,
        net_value: net_price * quantity))
    end

    def submit(customer_id:)
      raise NotAllowed unless @state == :draft
      raise Invalid    if @items.empty?
      net_total = calculate_net_total
      apply(OrderSubmitted.new(
        order_number: number,
        customer_id:  customer_id,
        items:        items,
        net_total:    net_total,
        fee:          fee_calculator.call(net_total)))
    end

    def cancel
      raise NotAllowed unless [:draft, :submitted].include?(@state)
      apply(OrderCancelled.new(
        order_number: number))
    end

    def expire
      raise NotAllowed unless @state == :draft
      apply(OrderExpired.new(
        order_number: number))
    end

    def ship
      raise NotAllowed unless @state == :submitted
      apply(OrderShipped.new(
        order_number: number))
    end

    private
    def apply_strategy
      ->(aggregate, event) {
        {
          Orders::OrderItemAdded  => aggregate.method(:apply_item_added),
          Orders::OrderSubmitted  => aggregate.method(:apply_submitted),
          Orders::OrderCancelled  => aggregate.method(:apply_cancelled),
          Orders::OrderExpired    => aggregate.method(:apply_expired),
          Orders::OrderShipped    => aggregate.method(:apply_shipped),
        }.fetch(event.class).call(event)
      }
    end

    def apply_item_added(ev)
      items.add({
        sku: sku,
        quantity: quantity,
        net_price: net_price,
        vat_rate: vat_rate,
      })
    end

    def apply_submitted(ev)
      @state = :submitted
    end

    def apply_cancelled(ev)
      @state = :cancelled
    end

    def apply_expired(ev)
      @state = :expired
    end

    def apply_shipped(ev)
      @state = :shipped
    end

    def calculate_net_total
      items.sum{|i| i[:quantity] * i[:net_price]}
    end
  end
end
