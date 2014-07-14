class AddDataSourceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :data_source, :integer, default: 0
  end
end
