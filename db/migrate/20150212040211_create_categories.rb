class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.string     :name,                null: false, limit: 40
      t.string     :lcbo_ref,            null: false, limit: 40
      t.references :parent_category
      t.integer    :parent_category_ids, null: false, array: true, default: []
      t.boolean    :is_dead,             null: false, default: false
      t.column     :depth,    :smallint, null: false

      t.timestamps null: false
    end

    add_index :categories, :name
    add_index :categories, :lcbo_ref
    add_index :categories, :depth
    add_index :categories, :parent_category_id
    add_index :categories, :parent_category_ids, using: :gin
    add_index :categories, :is_dead
    add_index :categories, :created_at
    add_index :categories, :updated_at
  end
end
