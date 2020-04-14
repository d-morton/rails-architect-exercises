class PaymentsProjection
  def initialize(event_store = Rails.application.config.event_store)
    @event_store = event_store
  end

  def call(event)
    @event_store.with_metadata(correlation_id: event.event_id) do
      event_projection = event.class.new(
        data: event.data,
        metadata: event.metadata
      )
      stream = "OrderPayment$#{event.data[:order_number]}"
      @event_store.append(event_projection, stream_name: stream)
    end
  end
end
