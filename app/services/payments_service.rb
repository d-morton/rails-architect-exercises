require 'arkency/command_bus'

class PaymentsService
  def initialize(store:, payment_gateway:)
    @repository       = AggregateRoot::Repository.new(store)
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

  def authorize(cmd)
    payment = Payments::Payment.new(payment_gateway: @payment_gateway)
    payment.authorize(
      order_number: cmd.order_number,
      total_amount: cmd.total_amount,
      card_number:  cmd.card_number)
    stream = payment.transaction_identifier.present? ?
      "Payment$#{payment.transaction_identifier}" :
      "failed-transactions"
    @repository.store(payment, stream)
  end

  def capture(cmd)
    @repository.with_aggregate(
      Payments::Payment.new(payment_gateway: @payment_gateway),
      "Payment$#{cmd.transaction_identifier}"
    ) do |payment|
      payment.capture
    end
  end

  def release(cmd)
    @repository.with_aggregate(
      Payments::Payment.new(payment_gateway: @payment_gateway),
      "Payment$#{cmd.transaction_identifier}"
    ) do |payment|
      payment.release
    end
  end
end
