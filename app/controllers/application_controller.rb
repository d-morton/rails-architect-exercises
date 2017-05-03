class ApplicationController < ActionController::Base

  def command_bus
    Rails.configuration.command_bus
  end

  def event_store
    Rails.application.config.event_store
  end

  protect_from_forgery with: :exception
end
