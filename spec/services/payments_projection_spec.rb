RSpec.describe PaymentsProjection do
  specify do
    es = RailsEventStore::Client.new
    es.subscribe(PaymentsProjection.new(es), to: [
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
    es.publish(payments_stream.first, stream_name: "failed-transactions")
    payments_stream.last(3).each do |ev|
      es.publish(ev, stream_name: "Payment$#{transaction_identifier}")
    end

    projection_stream = es.read.stream("OrderPayment$#{order_number}").each
    expect(projection_stream.map(&:data)).to eq(payments_stream.map(&:data))
    expect(projection_stream.map{ |e| e.metadata[:correlation_id] })
      .to eq(payments_stream.map(&:event_id))
  end
end
