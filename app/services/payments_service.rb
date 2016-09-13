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
    repository = AggregateRoot::Repository.new(@store)
    payment = Payments::Payment.new(transaction_identifier: identifier,
                                    payment_gateway: @payment_gateway)
    repository.load(payment)
    yield payment
    repository.store(payment)
  end

  def authorize(cmd)
    repository = AggregateRoot::Repository.new(@store)
    payment = Payments::Payment.new(transaction_identifier: nil,
                                    payment_gateway: @payment_gateway)
    payment.authorize(
      order_number: cmd.order_number,
      total_amount: cmd.total_amount,
      card_number:  cmd.card_number)
    repository.store(payment)
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
