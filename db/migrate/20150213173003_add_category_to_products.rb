class AddCategoryToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :category, :string, limit: 140
  end
end
