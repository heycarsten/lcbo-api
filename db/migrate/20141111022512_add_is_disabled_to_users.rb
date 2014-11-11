class AddIsDisabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_disabled, :boolean, default: false, null: false
    add_index  :users, :is_disabled
  end
end
