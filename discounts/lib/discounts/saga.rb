module Discounts
  class Process < ApplicationJob
    queue_as :default

    class State < ActiveRecord::Base
      self.table_name = "discount_sagas"
      serialize :data

      def self.get_by_customer_id(customer_id)
        transaction do
          lock.find_or_create_by(customer_id: customer_id, state: "active").tap do |s|
            s.data ||= {orders: []}
            yield s
            s.save!
          end
        end
      rescue ActiveRecord::StatementInvalid => exc
        if exc.message =~ /Deadlock found/ # Mysql specific
          retry
        else
          raise
        end
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end

    class DiscardForDiscounts < Struct.new(:order_number, :customer_id)
      def data
        self
      end
    end

    def perform(serialized_event)
      event = YAML.load(serialized_event)
      State.get_by_customer_id(event.data[:customer_id]) do |state|
        case event
          when Orders::OrderShipped
            state.data[:orders] += [event.data[:order_number]]
            state.data[:orders] = state.data[:orders].uniq
            Discounts::Process.set(wait: 1.month).perform_later(YAML.dump( DiscardForDiscounts.new(event.data[:order_number], event.data[:customer_id]) ))
          when DiscardForDiscounts
            state.data[:orders] -= [event.order_number]
          else
            raise ArgumentError
        end
        if state.data[:orders].size == 3
          state.state = "completed"
          Discounts::Mailer.notify_about_discount(state.customer_id).deliver_later
        end
      end
    end

  end
end
