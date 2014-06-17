class AddSurrogatePkToInventories < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE inventories DROP CONSTRAINT inventories_pkey'
    add_column :inventories, :id, :primary_key
  end
end
