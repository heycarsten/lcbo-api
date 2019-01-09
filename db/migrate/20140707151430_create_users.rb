class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users, id: false do |t|
      t.primary_key :id, :uuid, default: 'uuid_generate_v1()'

      t.string :name
      t.string :email,               limit: 120
      t.string :password_digest,     limit: 60, null: false
      t.string :verification_secret, limit: 36, null: false
      t.string :auth_secret,         limit: 36, null: false
      t.string :last_seen_ip
      t.datetime :last_seen_at

      t.timestamps
    end
  end
end
