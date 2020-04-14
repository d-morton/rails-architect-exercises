require 'arkency/command_bus'

command_bus = Arkency::CommandBus.new

payments_service_handler = ->(c) do
  PaymentsService.new(
    store: Rails.application.config.event_store,
    payment_gateway: PaymentGateway.new
  ).call(c)
end
command_bus.register(Payments::AuthorizePaymentCommand, payments_service_handler)
command_bus.register(Payments::CapturePaymentCommand,   payments_service_handler)
command_bus.register(Payments::ReleasePaymentCommand,   payments_service_handler)

Rails.configuration.command_bus = command_bus
