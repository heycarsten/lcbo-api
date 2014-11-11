class AddPlanIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :plan_id, :uuid
  end
end
