module Orders
  class PaymentsProjection
    def initialize(event_store = Rails.application.config.event_store)
      @event_store = event_store
    end

    def call(event)
      event_projection = event.class.new(
        data: event.data,
        metadata: event.metadata.merge(correlation_id: event.event_id))
      stream = "OrderPayment$#{event.data[:order_number]}"
      event_store.append(event_projection, stream_name: stream)
    end

    private
    attr_reader :event_store
  end
end

