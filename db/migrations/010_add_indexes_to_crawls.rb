Sequel.migration do

  up do
    alter_table :crawls do
      add_index :total_products
      add_index :total_stores
      add_index :total_inventories
      add_index :total_product_inventory_count
      add_index :total_product_inventory_volume_in_milliliters
      add_index :total_product_inventory_price_in_cents
    end
  end

  down do
    alter_table :crawls do
      remove_index :total_products
      remove_index :total_stores
      remove_index :total_inventories
      remove_index :total_product_inventory_count
      remove_index :total_product_inventory_volume_in_milliliters
      remove_index :total_product_inventory_price_in_cents
    end
  end

end
