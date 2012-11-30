Sequel.migration do
  up do
    alter_table :products do
      # Sugar Content is now the sweetness descriptor so it needs more space
      set_column_type :sugar_content, :varchar, :size => 100

      # Add all the new shit
      add_column :varietal,                        :varchar,  :size => 100
      add_column :style,                           :varchar,  :size => 100
      add_column :tertiary_category,               :varchar,  :size => 32
      add_column :sugar_in_grams_per_liter,        :smallint, :default => 0
      add_column :clearance_sale_savings_in_cents, :smallint, :default => 0
      add_column :has_clearance_sale,              :boolean,  :default => false
    end
  end

  down do
    alter_table :products do
      set_column_type :sugar_content, :varchar, :size => 6
      drop_column :sugar_in_grams_per_liter
      drop_column :varietal
      drop_column :style
      drop_column :clearance_sale_savings_in_cents
      drop_column :has_clearance_sale
      drop_column :tertiary_category
    end
  end
end
