class CreateDiscountSagasStateTable < ActiveRecord::Migration[5.0]
  def change
    create_table :discount_sagas do |t|
      t.references :customer, null: false
      t.string :state, null: false
      t.binary :data
    end
    add_index(
      :discount_sagas,
      [:customer_id],
      unique: true,
      where: "state = 'active'",
      name: "index_active_discount_sagas_on_customer_id"
    )
  end
end