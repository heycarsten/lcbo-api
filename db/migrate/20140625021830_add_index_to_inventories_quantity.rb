class AddIndexToInventoriesQuantity < ActiveRecord::Migration
  def change
    add_index :inventories, :quantity
  end
end
