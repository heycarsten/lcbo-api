class AddValueAddedPromotionEndsOnToProducts < ActiveRecord::Migration[4.2]
  def change
    add_column :products, :value_added_promotion_ends_on, :date
    add_index :products, :value_added_promotion_ends_on
  end
end
