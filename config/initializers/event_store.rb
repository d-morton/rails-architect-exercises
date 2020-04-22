def instance_of(klass, *args)
  ->(event) { klass.new(*args).call(event) }
end

Rails.application.config.event_store.tap do |es|
  es.subscribe(instance_of(OrderList::OrderSubmittedHandler), to: [Orders::OrderSubmitted])
  es.subscribe(instance_of(OrderList::OrderCancelledHandler), to: [Orders::OrderCancelled])
  es.subscribe(instance_of(OrderList::OrderShippedHandler), to: [Orders::OrderShipped])
  es.subscribe(instance_of(OrderList::OrderExpiredHandler), to: [Orders::OrderExpired])
  es.subscribe(instance_of(OrderList::OrderPaidHandler), to: [Payments::PaymentAuthorized])
  es.subscribe(instance_of(OrderList::OrderPaymentFailedHandler), to: [Payments::PaymentAuthorizationFailed])
  es.subscribe(instance_of(Orders::PaymentsProjection), to: [
    Payments::PaymentAuthorized,
    Payments::PaymentCaptured,
    Payments::PaymentReleased,
    Payments::PaymentAuthorizationFailed,
  ])

  es.subscribe(instance_of(Orders::ScheduleExpireOnSubmit, ExpireOrderJob), to: [Orders::OrderSubmitted])

  es.subscribe(to: [Orders::OrderShipped]) do |event|
    Discounts::Process.perform_later(YAML.dump(event))
  end
end
