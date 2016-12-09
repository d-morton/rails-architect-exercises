RSpec.describe PaymentsProjection do
  specify do
    es = RailsEventStore::Client.new
    es.subscribe(PaymentsProjection.new(es), [
      Payments::PaymentAuthorized,
      Payments::PaymentCaptured,
      Payments::PaymentReleased,
      Payments::PaymentAuthorizationFailed,
    ])

    order_number           = SecureRandom.hex
    transaction_identifier = SecureRandom.hex

    payments_stream = [
      Payments::PaymentAuthorizationFailed.new(data: {
        order_number: order_number}),
      Payments::PaymentAuthorized.new(data: {
        order_number: order_number,
        transaction_identifier: transaction_identifier}),
      Payments::PaymentCaptured.new(data: {
        order_number: order_number,
        transaction_identifier: transaction_identifier}),
      Payments::PaymentReleased.new(data: {
        order_number: order_number,
        transaction_identifier: transaction_identifier}),
    ]
    es.publish_event(payments_stream.first, stream_name: "failed-transactions")
    payments_stream.last(3).each do |ev|
      es.publish_event(ev, stream_name: "Payment$#{transaction_identifier}")
    end

    projection_stream = es.read_stream_events_forward("OrderPayment$#{order_number}")
    expect(projection_stream.map(&:data)).to eq(payments_stream.map(&:data))
    expect(projection_stream.map(&:metadata)).to eq(payments_stream.map{|ev| ev.metadata.merge(correlation_id: ev.event_id)})
  end
end
