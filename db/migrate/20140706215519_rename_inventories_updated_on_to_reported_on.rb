class RenameInventoriesUpdatedOnToReportedOn < ActiveRecord::Migration[4.2]
  def change
    rename_column :inventories, :updated_on, :reported_on
  end
end
