class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories, id: false do |t|
      t.primary_key :id, :uuid, default: 'uuid_generate_v1()'

      t.string   :name,     null: false, limit: 40
      t.string   :slug,     null: false, limit: 40
      t.string   :lcbo_ref, null: false, limit: 40
      t.column   :depth,    :smallint, null: false
      t.boolean  :is_dead,  null: false, default: false

      t.uuid :parent_category_id

      t.timestamps null: false
    end

    add_index :categories, [:slug, :depth], unique: true
    add_index :categories, :lcbo_ref
    add_index :categories, :is_dead
    add_index :categories, :parent_category_id
  end
end
