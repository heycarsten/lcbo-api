class AddCategoryIdsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :category_ids, :uuid, array: true, default: [], null: false
    add_index :products, :category_ids, using: :gin
  end
end
