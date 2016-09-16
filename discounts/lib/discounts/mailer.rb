module Discounts
  class Mailer < ActionMailer::Base
    prepend_view_path "discounts/views/"

    def notify_about_discount(customer_id)
      mail(
        from:    "info@example.org",
        to:      ["discounts@example.org"],
        subject: "New discount required"
      ) do |format|
        format.text { render text: "CustomerID: #{customer_id}" }
      end
    end

  end
end