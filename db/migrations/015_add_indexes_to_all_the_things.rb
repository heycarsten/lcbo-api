Sequel.migration do
  up do
    alter_table :products do
      add_index :varietal,                        :nulls => :last
      add_index :style,                           :nulls => :last
      add_index :tertiary_category,               :nulls => :last
      add_index :sugar_in_grams_per_liter,        :nulls => :last
      add_index :clearance_sale_savings_in_cents, :nulls => :last
    end
  end
end
