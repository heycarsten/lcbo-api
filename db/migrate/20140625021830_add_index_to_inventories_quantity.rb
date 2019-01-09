class AddIndexToInventoriesQuantity < ActiveRecord::Migration[4.2]
  def change
    add_index :inventories, :quantity
  end
end
