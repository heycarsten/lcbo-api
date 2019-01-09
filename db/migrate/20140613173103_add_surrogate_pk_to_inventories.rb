class AddSurrogatePkToInventories < ActiveRecord::Migration[4.2]
  def up
    execute 'ALTER TABLE inventories DROP CONSTRAINT inventories_pkey'
    add_column :inventories, :id, :primary_key
  end
end
