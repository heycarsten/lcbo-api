class AddIsOcbToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :is_ocb, :boolean, null: false, default: false
    add_index :products, :is_ocb
  end
end
