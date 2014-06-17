Sequel.migration do

  up do
    alter_table :products do
      set_column_type :clearance_sale_savings_in_cents,     :integer
      set_column_type :limited_time_offer_savings_in_cents, :integer
    end
  end

end
