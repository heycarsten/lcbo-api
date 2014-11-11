class ChangeKeysYetAgain < ActiveRecord::Migration
  def change
    remove_column :keys, :is_public
    remove_column :keys, :max_rate

    add_column :keys, :kind, :integer, default: 0
  end
end
