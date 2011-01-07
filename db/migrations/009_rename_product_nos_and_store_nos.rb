Sequel.migration do

  up do
    alter_table :crawls do
      rename_column :store_nos,           :store_ids
      rename_column :product_nos,         :product_ids
      rename_column :added_product_nos,   :added_product_ids
      rename_column :added_store_nos,     :added_store_ids
      rename_column :removed_product_nos, :removed_product_ids
      rename_column :removed_store_nos,   :removed_store_ids
    end
  end

  down do
    alter_table :crawls do
      rename_column :store_ids,           :store_nos
      rename_column :product_ids,         :product_nos
      rename_column :added_product_ids,   :added_product_nos
      rename_column :added_store_ids,     :added_store_nos
      rename_column :removed_product_ids, :removed_product_nos
      rename_column :removed_store_ids,   :removed_store_nos
    end
  end

end
