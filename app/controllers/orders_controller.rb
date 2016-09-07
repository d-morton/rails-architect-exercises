class OrdersController < ApplicationController
  def index
    @orders = Order.all
  end

  def show
  end

  def new
    @products  = Product.all
    @customers = []
  end

  def create
    cmd = Orders::SubmitOrderCommand.new(
      order_number: order_number,
      items: order_items,
      customer_id: params[:customer_id])
    service.call(cmd)
    redirect_to orders_url, notice: 'Your order was submitted.'
  rescue
    redirect_to orders_url, notice: 'Could not submit the order.'
  end

  def destroy
    order = Order.find(params[:id])
    cmd = Orders::CancelOrderCommand.new(order_number: order.number)
    service.call(cmd)
    redirect_to orders_url, notice: 'Order was cancelled.'
  rescue
    redirect_to orders_url, notice: 'Could not cancel the order.'
  end

  def ship
    order = Order.find(params[:id])
    cmd = Orders::ShipOrderCommand.new(order_number: order.number)
    service.call(cmd)
    redirect_to orders_url, notice: 'Order shipment was initiated.'
  rescue
    redirect_to orders_url, notice: 'Could not ship the order.'
  end

  private
  def service
    OrdersService.new(store: Rails.application.config.event_store)
  end

  def order_number
    "#{Time.now.year}-#{Time.now.month}-#{SecureRandom.hex}"
  end

  def order_items
    items = params[:quantity].map(&:to_i).map.with_index { |quantity,index|
      [quantity, Product.find(params[:products][index])] if quantity > 0
    }.compact.to_h
    items.map {|q, p|
      {sku: p.id, quantity: q, net_price: p.net_price, vat_rate: p.vat_rate}
    }
  end
end
