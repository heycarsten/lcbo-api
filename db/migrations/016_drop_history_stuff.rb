Sequel.migration do
  up do
    drop_table :product_revisions
    drop_table :store_revisions
    drop_table :inventory_revisions
  end
end
