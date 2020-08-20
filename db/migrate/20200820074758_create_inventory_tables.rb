class CreateInventoryTables < ActiveRecord::Migration[5.2]
  def change
    create_table :inventory_stores do |t|
      t.string :name
      t.text :data
    end

    create_table :inventory_products do |t|
      t.integer :store_id,           null: false
      t.string  :sku,                null: false
      t.integer :quantity_available, null: false
      t.integer :quantity_shipped,   null: false
      t.integer :quantity_reserved,  null: false
    end

    create_table :inventory_shipments do |t|
      t.integer :store_id,           null: false
      t.string :state, null: false
      t.string :order_number, null: false
      t.text :data
    end
  end
end
