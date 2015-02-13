class AddProducerIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :producer_id, :integer
    add_index :products, :producer_id
  end
end
