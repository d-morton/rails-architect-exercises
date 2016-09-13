class ExpireOrderJob < ApplicationJob
  queue_as :default

  def perform(order_number)
    OrdersService.new(store: Rails.application.config.event_store).call(
      Orders::ExpireOrderCommand.new(order_number: order_number))
  end
end
