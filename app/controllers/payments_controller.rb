class PaymentsController < ApplicationController
  def create
    order = OrderList::Order.find_by(number: params[:order_number])
    cmd = Payments::AuthorizePaymentCommand.new(
      order_number: order.number,
      total_amount: order.gross_value,
      card_number:  params[:card_number])
    command_bus.call(cmd)
    redirect_to orders_url, notice: 'Order paid.'
  rescue
    redirect_to orders_url, notice: "Payment failed"
  end

end