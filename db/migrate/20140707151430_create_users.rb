class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: false do |t|
      t.primary_key :id, :uuid, default: 'uuid_generate_v1()'

      t.string :name
      t.string :email
      t.string :new_email
      t.string :password_digest,    limit: 60, null: false
      t.string :verification_token, limit: 36
      t.string :auth_token,         limit: 36, null: false
      t.string :last_seen_ip
      t.datetime :last_seen_at

      t.timestamps
    end

    add_index :users, :email,     unique: true, where: 'email IS NOT NULL'
    add_index :users, :new_email, unique: true, where: 'new_email IS NOT NULL'
  end
end
