class CreateProducers < ActiveRecord::Migration
  def change
    create_table :producers, id: false do |t|
      t.primary_key :id, :uuid, default: 'uuid_generate_v1()'

      t.string :name,      null: false, limit: 80
      t.string :lcbo_name, null: false, limit: 100
      t.string :slug,      null: false, limit: 80
      t.string :lcbo_slug, null: false, limit: 100

      t.boolean :is_dead,      default: false, null: false
      t.boolean :is_ocb,       default: false, null: false

      t.timestamps null: false
    end

    add_index :producers, :slug,      unique: true
    add_index :producers, :lcbo_slug, unique: true
    add_index :producers, :is_dead
  end
end
