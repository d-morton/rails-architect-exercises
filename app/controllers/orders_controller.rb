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
    redirect_to orders_url, notice: 'Your order was submitted.'
  end

  def destroy
    redirect_to orders_url, notice: 'Order was cancelled.'
  end

  def ship
    redirect_to orders_url, notice: 'Order shipment was initiated.'
  end

  private
end
