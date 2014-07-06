class RenameInventoriesUpdatedOnToReportedOn < ActiveRecord::Migration
  def change
    rename_column :inventories, :updated_on, :reported_on
  end
end
