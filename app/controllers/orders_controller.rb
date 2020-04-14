class OrdersController < ApplicationController
  def index
    @orders = OrderList::Order.all
  end

  def show
    order = OrderList::Order.find(params[:id])
    order_history = event_store.read.stream("Order$#{order.number}").backward.to_a
    payment_history = event_store.read.stream("OrderPayment$#{order.number}").backward.to_a
    @history = (order_history + payment_history).sort_by{|x| x.metadata[:timestamp]}.reverse
  end

  def new
    @products  = Orders::Product.all
    @customers = Orders::Customer.all
  end

  def create
    cmd = Orders::SubmitOrderCommand.new(
      items: order_items,
      customer_id: params[:customer_id])
    service.call(cmd)
    redirect_to orders_url, notice: 'Your order was submitted.'
  rescue Orders::Order::Invalid
    redirect_to orders_url, notice: "Could not submit the order, didn't you forget to add anything?"
  rescue Orders::Order::NotAllowed
    redirect_to orders_url, notice: "Could not submit the order."
  end

  def destroy
    order = OrderList::Order.find(params[:id])
    cmd = Orders::CancelOrderCommand.new(order_number: order.number)
    service.call(cmd)
    redirect_to orders_url, notice: 'Order was cancelled.'
  rescue Orders::Order::NotAllowed
    redirect_to orders_url, notice: "Could not cancel the order."
  end

  def pay
    @order = OrderList::Order.find(params[:order_id])
  end

  def ship
    order = OrderList::Order.find(params[:order_id])
    cmd = Orders::ShipOrderCommand.new(order_number: order.number)
    service.call(cmd)
    redirect_to orders_url, notice: 'Order shipment was initiated.'
  rescue Orders::Order::NotAllowed
    redirect_to orders_url, notice: "Could not ship the order."
  end

  private
  def service
    OrdersService.new(store: event_store,
                      pricing: ->(sku) { p = Orders::Product.find(sku); {net_price: p.net_price, vat_rate: p.vat_rate} })
  end

  def order_items
    params[:quantity].map(&:to_i).map.with_index { |quantity,index|
      {sku: params[:products][index], quantity: quantity} if quantity > 0
    }.compact
  end
end
