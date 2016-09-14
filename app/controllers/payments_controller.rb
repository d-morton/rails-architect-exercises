class PaymentsController < ApplicationController
  def create
    order = OrderList::Order.find_by(number: params[:order_number])
    cmd = Payments::AuthorizePaymentCommand.new(
      order_number: order.number,
      total_amount: order.gross_value,
      card_number:  params[:card_number])
    service.call(cmd)
    redirect_to orders_url, notice: 'Your order was submitted.'
  rescue
    redirect_to orders_url, notice: "Payment failed"
  end

  private
  def service
    PaymentsService.new(store: Rails.application.config.event_store,
                        payment_gateway: PaymentGateway.new)
  end
end
