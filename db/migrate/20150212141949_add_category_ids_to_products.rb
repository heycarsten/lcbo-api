class AddCategoryIdsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :category_ids, :integer, array: true, default: [], null: false
    add_index :products,  :category_ids, using: :gin
  end
end
