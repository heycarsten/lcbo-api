class DropSequelSchemaInfo < ActiveRecord::Migration
  def up
    # Remove sequel schema_info table
    drop_table :schema_info
  end
end
