class CreateProducers < ActiveRecord::Migration[5.0]
  def change
    create_table :producers do |t|
      t.string  :name,     null: false, limit: 80
      t.string  :lcbo_ref, null: false, limit: 100
      t.boolean :is_dead,  null: false, default: false
      t.boolean :is_ocb,   null: false, default: false

      t.timestamps null: false
    end

    add_index :producers, :lcbo_ref, unique: true
    add_index :producers, :is_dead
    add_index :producers, :is_ocb
    add_index :producers, :name
    add_index :producers, :created_at
    add_index :producers, :updated_at
  end
end
