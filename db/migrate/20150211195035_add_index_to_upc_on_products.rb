class AddIndexToUpcOnProducts < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :upc, :bigint, using: 'upc::bigint'
    change_column :products, :scc, :bigint, using: 'upc::bigint'

    add_index :products, :upc
  end
end
