Sequel.migration do
  up do
    alter_table :products do
      add_column :image_thumb_url, :varchar, :size => 100
      add_column :image_url,       :varchar, :size => 100
    end
  end
end
