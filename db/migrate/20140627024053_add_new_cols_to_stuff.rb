class AddNewColsToStuff < ActiveRecord::Migration[4.2]
  def change
    add_column :stores,   :kind,          :string
    add_column :stores,   :landmark_name, :string
    add_column :products, :upc,           :string
    add_column :products, :scc,           :string
    add_column :products, :style_flavour, :string
    add_column :products, :style_body,    :string
  end
end
