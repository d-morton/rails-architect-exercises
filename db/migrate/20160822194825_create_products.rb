class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :net_price
      t.integer :vat_rate

      t.timestamps
    end
  end
end
