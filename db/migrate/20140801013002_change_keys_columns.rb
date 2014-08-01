class ChangeKeysColumns < ActiveRecord::Migration
  def change
    add_column :keys, :is_public, :boolean, default: false, null: false
    add_column :keys, :domain,    :string,  limit: 100
    add_column :keys, :max_rate,  :integer
  end
end
