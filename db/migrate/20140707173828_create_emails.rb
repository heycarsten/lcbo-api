class CreateEmails < ActiveRecord::Migration[4.2]
  def change
    create_table :emails, id: false do |t|
      t.primary_key :id, :uuid, default: 'uuid_generate_v1()'

      t.uuid    :user_id,             null: false
      t.string  :address,             null: false, limit: 120
      t.boolean :is_verified,         null: false, default: false
      t.string  :verification_secret, null: false, limit: 36

      t.timestamps
    end

    add_index :emails, :user_id
    add_index :emails, [:is_verified, :address]
    add_index :emails, :address, unique: true
  end
end
