def instance_of(klass, *args)
  ->(event) { klass.new(*args).call(event) }
end

Rails.application.config.event_store.tap do |es|
  es.subscribe(instance_of(ReadModel::OrderSubmittedHandler), [Orders::OrderSubmitted])
  es.subscribe(instance_of(ReadModel::OrderCancelledHandler), [Orders::OrderCancelled])
  es.subscribe(instance_of(ReadModel::OrderShippedHandler), [Orders::OrderShipped])
  es.subscribe(instance_of(ReadModel::OrderExpiredHandler), [Orders::OrderExpired])
  es.subscribe(instance_of(Orders::ScheduleExpireOnSubmit, ExpireOrderJob), [Orders::OrderSubmitted])
end
