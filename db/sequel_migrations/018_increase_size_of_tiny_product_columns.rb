Sequel.migration do
  up do
    alter_table :products do
      set_column_type :primary_category,   :varchar, size: 60
      set_column_type :secondary_category, :varchar, size: 60
      set_column_type :tertiary_category,  :varchar, size: 60
    end
  end
end
