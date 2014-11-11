class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans, id: false do |t|
      t.primary_key :id, :uuid, default: 'uuid_generate_v4()'

      t.boolean :is_active,                    default: true,   null: false
      t.string  :stripe_uid, limit: 45
      t.string  :title,      limit: 60
      t.integer :kind,                         default: 0,      null: false
      t.boolean :has_cors,                     default: false,  null: false
      t.boolean :has_ssl,                      default: false,  null: false
      t.boolean :has_upc_lookup,               default: false,  null: false
      t.boolean :has_upc_value,                default: false,  null: false
      t.boolean :has_history,                  default: false,  null: false
      t.integer :request_pool_size,            default: 65_000, null: false
      t.integer :fee_in_cents,                 default: 0,      null: false
      t.timestamps
    end

    add_index :plans, :is_active
  end
end
