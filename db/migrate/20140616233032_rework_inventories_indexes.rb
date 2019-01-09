class ReworkInventoriesIndexes < ActiveRecord::Migration[4.2]
  def change
    remove_index :inventories, name: 'idx_inventories_product_id_store_id_where_quantity_gt_0'
    add_index :inventories, [:product_id, :store_id]
    add_index :inventories, :store_id
    add_index :inventories, :product_id
  end
end
