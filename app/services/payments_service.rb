require 'arkency/command_bus'

class PaymentsService
  def initialize(store:, payment_gateway:)
    @store            = store
    @payment_gateway  = payment_gateway

    @command_bus      = Arkency::CommandBus.new
    { Payments::AuthorizePaymentCommand => method(:authorize),
      Payments::CapturePaymentCommand   => method(:capture),
      Payments::ReleasePaymentCommand   => method(:release),
    }.map{|klass, handler| @command_bus.register(klass, handler)}
  end

  def call(*commands)
    commands.each do |cmd|
      @command_bus.call(cmd)
    end
  end

  private

  def with_payment(identifier)
    stream = "Payment$#{identifier}"
    payment = Payments::Payment.new(payment_gateway: @payment_gateway)
    payment.load(stream, event_store: @store)
    yield payment
    payment.store(stream, event_store: @store)
  end

  def authorize(cmd)
    payment = Payments::Payment.new(payment_gateway: @payment_gateway)
    payment.authorize(
      order_number: cmd.order_number,
      total_amount: cmd.total_amount,
      card_number:  cmd.card_number)
    stream = "Payment$#{payment.transaction_identifier}"
    payment.store(stream, event_store: @store)
  rescue Payments::PaymentAuthorizationFailed
    payment.store('failed-transactions', event_store: @store)
    raise
  end

  def capture(cmd)
    with_payment(cmd.transaction_identifier) do |payment|
      payment.capture
    end
  end

  def release(cmd)
    with_payment(cmd.transaction_identifier) do |payment|
      payment.capture
    end
  end
end
