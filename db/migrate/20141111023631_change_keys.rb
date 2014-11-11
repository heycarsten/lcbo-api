class ChangeKeys < ActiveRecord::Migration
  def change
    add_column :keys, :in_devmode,  :boolean, default: false, null: false
    add_column :keys, :is_disabled, :boolean, default: false, null: false
  end
end
