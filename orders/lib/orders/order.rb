require 'aggregate_root'

module Orders
  class Order
    include AggregateRoot
    NotAllowed = Class.new(StandardError)
    Invalid    = Class.new(StandardError)

    def initialize(number:, fee_calculator: FeeCalculator.new)
      @number         = number
      @state          = :draft
      @items          = []
      @fee_calculator = fee_calculator
    end

    def add_item(sku:, quantity:, net_price:, vat_rate:)
      raise NotAllowed unless state == :draft
      raise ArgumentError unless sku.to_s.present?
      raise ArgumentError unless quantity > 0
      raise ArgumentError unless net_price > 0
      raise ArgumentError if vat_rate < 0 || vat_rate >= 100

      net_value   = quantity * net_price
      vat_amount  = net_value * (vat_rate / 100.0.to_d)
      gross_value = net_value + vat_amount

      apply(OrderItemAdded.new(data: {
        order_number: number,
        sku: sku,
        quantity: quantity,
        net_price: net_price,
        net_value: net_value,
        vat_amount: vat_amount,
        gross_value: gross_value}))
    end

    def submit(customer_id:)
      raise NotAllowed unless state == :draft
      raise Invalid    if items.empty?

      net_total = items.sum{|i| i[:net_value]}
      gross_total = items.sum{|i| i[:gross_value]}
      fee = fee_calculator.call(gross_total)
      vat_total = items.sum{|i| i[:vat_amount]}

      apply(OrderSubmitted.new(data: {
        order_number: number,
        customer_id:  customer_id,
        items_count:  items.sum{|i| i[:quantity]},
        net_total:    net_total,
        vat_total:    vat_total,
        gross_total:  gross_total,
        fee:          fee}))
    end

    def cancel
      raise NotAllowed unless [:draft, :submitted].include?(state)
      apply(OrderCancelled.strict(data: {
        order_number: number}))
    end

    def expire
      return if [:expired, :shipped].include?(state)
      apply(OrderExpired.strict(data: {
        order_number: number}))
    end

    def ship
      raise NotAllowed unless state == :submitted
      apply(OrderShipped.strict(data: {
        order_number: number,
        customer_id: customer_id,
      }))
    end

    private
    attr_reader :number, :state, :items, :fee_calculator, :customer_id

    def apply_strategy
      ->(aggregate, event) {
        {
          Orders::OrderItemAdded => aggregate.method(:apply_item_added),
          Orders::OrderSubmitted => aggregate.method(:apply_submitted),
          Orders::OrderCancelled => aggregate.method(:apply_cancelled),
          Orders::OrderExpired   => aggregate.method(:apply_expired),
          Orders::OrderShipped   => aggregate.method(:apply_shipped),
        }.fetch(event.class).call(event)
      }
    end

    def apply_item_added(ev)
      @items << {
        sku:          ev.data[:sku],
        quantity:     ev.data[:quantity],
        net_price:    ev.data[:net_price],
        net_value:    ev.data[:net_value],
        vat_amount:   ev.data[:vat_amount],
        gross_value:  ev.data[:gross_value],
      }
    end

    def apply_submitted(ev)
      @state = :submitted
      @customer_id = ev.data[:customer_id]
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
  end
end
