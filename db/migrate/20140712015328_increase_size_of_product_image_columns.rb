class IncreaseSizeOfProductImageColumns < ActiveRecord::Migration[4.2]
  def change
    change_column :products, :image_url,       :string, limit: 120
    change_column :products, :image_thumb_url, :string, limit: 120
  end
end
