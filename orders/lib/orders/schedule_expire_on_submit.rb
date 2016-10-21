module Orders
  class ScheduleExpireOnSubmit
    def initialize(handler_class)
      @handler_class = handler_class
    end

    def call(event)
      @handler_class.set(wait: 15.minutes).perform_later(event.data[:order_number])
    end
  end
end
