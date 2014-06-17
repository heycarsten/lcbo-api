Sequel.migration do
  up do
    alter_table :inventories do
      set_column_type :quantity, :integer
    end

    alter_table :inventory_revisions do
      set_column_type :quantity, :integer
    end
  end
end
