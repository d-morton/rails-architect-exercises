class ExpireOrderJob < ApplicationJob
  queue_as :default

  def perform(serialized_event)
    event = YAML.load(serialized_event)
    OrdersService.new(store: Rails.application.config.event_store).call(
      Orders::ExpireOrderCommand.new(order_number: event.data.order_number))
  end
end
