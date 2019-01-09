class AddDataSourceToProducts < ActiveRecord::Migration[4.2]
  def change
    add_column :products, :data_source, :integer, default: 0
  end
end
