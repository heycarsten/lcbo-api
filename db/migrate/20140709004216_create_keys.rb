class CreateKeys < ActiveRecord::Migration
  def change
    create_table :keys, id: false do |t|
      t.primary_key :id, :uuid, default: 'uuid_generate_v1()'
      t.references :user

      t.string  :secret, size: 12,  null: false
      t.string  :label,  size: 80
      t.integer :usage
      t.string  :url,    size: 255
      t.text    :info

      t.timestamps
    end

    add_index :keys, :user_id
  end
end
