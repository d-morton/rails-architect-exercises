class AddPaymentGatewayTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_gateway_transactions do |t|
      t.string  :identifier, null: false
      t.decimal :amount, null: false
      t.string  :card_number, null: false
      t.string  :state, null: false
    end
    add_index :payment_gateway_transactions, :identifier
  end
end
