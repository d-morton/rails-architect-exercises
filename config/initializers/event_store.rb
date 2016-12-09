def instance_of(klass, *args)
  ->(event) { klass.new(*args).call(event) }
end

Rails.application.config.event_store.tap do |es|
  es.subscribe(instance_of(OrderList::OrderSubmittedHandler), [Orders::OrderSubmitted])
  es.subscribe(instance_of(OrderList::OrderCancelledHandler), [Orders::OrderCancelled])
  es.subscribe(instance_of(OrderList::OrderShippedHandler), [Orders::OrderShipped])
  es.subscribe(instance_of(OrderList::OrderExpiredHandler), [Orders::OrderExpired])
  es.subscribe(instance_of(OrderList::OrderPaidHandler), [Payments::PaymentAuthorized])
  es.subscribe(instance_of(OrderList::OrderPaymentFailedHandler), [Payments::PaymentAuthorizationFailed])
  es.subscribe(instance_of(Orders::PaymentsProjection), [
    Payments::PaymentAuthorized,
    Payments::PaymentCaptured,
    Payments::PaymentReleased,
    Payments::PaymentAuthorizationFailed,
  ])

  es.subscribe(instance_of(Orders::ScheduleExpireOnSubmit, ExpireOrderJob), [Orders::OrderSubmitted])

  es.subscribe(->(event){ Discounts::Saga.perform_later(YAML.dump(event)) }, [Orders::OrderShipped])
end
