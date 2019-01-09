class AddCatalogRefsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :catalog_refs, :integer, array: true, null: false, default: []
    add_index :products, :catalog_refs, using: :gin
  end
end
