class AddUniqueIndexOnOrderNumber < ActiveRecord::Migration[5.0]
  def change
    add_index :orders, :number, unique: true
  end
end
