class ReworkKeys < ActiveRecord::Migration
  def change
    remove_column :keys, :usage, :integer
    remove_column :keys, :url,   :string
  end
end
