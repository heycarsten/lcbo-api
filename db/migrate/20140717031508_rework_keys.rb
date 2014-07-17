class ReworkKeys < ActiveRecord::Migration
  def change
    remove_column :keys, :usage, :integer
    remove_column :keys, :url,   :string
    remove_column :keys, :user_id
    add_column :keys, :user_id, :uuid, null: false
    add_index :keys, :user_id
  end
end
