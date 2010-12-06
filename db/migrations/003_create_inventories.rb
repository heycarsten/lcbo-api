Sequel.migration do

  up do
    create_table :inventories do |t|
      primary_key [:product_id, :store_id]
      foreign_key :product_id, :products, :on_delete => :cascade
      foreign_key :store_id,   :stores,   :on_delete => :cascade
      foreign_key :crawl_id
      boolean     :is_hidden,  :default => false, :index => true
      integer     :quantity,   :default => 0
      date        :updated_on
      datetime    :created_at, :null => false
      datetime    :updated_at, :null => false
    end
  end

  down do
    drop_table :inventories
  end

end
