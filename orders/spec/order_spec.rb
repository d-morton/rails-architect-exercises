require 'spec_helper'

module Orders
  describe Order do
    it 'order number is an aggregate id' do
      order = Order.new(number: '12345')
      expect(order.id).to eq('12345')
    end
  end
end
