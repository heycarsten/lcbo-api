class DropSequelSchemaInfo < ActiveRecord::Migration[4.2]
  def up
    # Remove sequel schema_info table
    drop_table :schema_info
  end
end
