class AddCategoryToProducts < ActiveRecord::Migration
  def change
    add_column :products, :category, :string, limit: 140
  end
end
