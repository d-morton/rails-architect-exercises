class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :number
      t.integer :items_count
      t.decimal :net_value
      t.decimal :vat_amount
      t.decimal :gross_value
      t.string :customer_name
      t.string :state

      t.timestamps
    end
  end
end
