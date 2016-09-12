class ExpireOrderJob < ApplicationJob
  queue_as :default

  def perform(serialized_command)
    OrdersService.new(store: Rails.application.config.event_store).call(
      YAML.load(serialized_command))
  end
end
