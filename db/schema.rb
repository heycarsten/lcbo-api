# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101201063820) do

  create_table "crawl_events", :force => true do |t|
    t.integer  "crawl_id"
    t.string   "level",      :limit => 25
    t.string   "message"
    t.text     "payload"
    t.datetime "created_at"
  end

  add_index "crawl_events", ["crawl_id"], :name => "index_crawl_events_on_crawl_id"

  create_table "crawls", :force => true do |t|
    t.integer  "crawl_event_id"
    t.string   "state"
    t.text     "added_store_nos"
    t.text     "removed_store_nos"
    t.text     "added_product_nos"
    t.text     "removed_product_nos"
    t.integer  "total_products",                                :default => 0
    t.integer  "total_stores",                                  :default => 0
    t.integer  "total_inventories",                             :default => 0
    t.integer  "total_product_inventory_count",                 :default => 0
    t.integer  "total_product_inventory_volume_in_milliliters", :default => 0
    t.integer  "total_product_inventory_price_in_cents",        :default => 0
    t.integer  "total_jobs",                                    :default => 0
    t.integer  "total_finished_jobs",                           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "crawls", ["created_at"], :name => "index_crawls_on_created_at"
  add_index "crawls", ["state"], :name => "index_crawls_on_state"
  add_index "crawls", ["updated_at"], :name => "index_crawls_on_updated_at"

  create_table "inventories", :force => true do |t|
    t.integer  "product_id"
    t.integer  "store_id"
    t.integer  "crawl_id"
    t.boolean  "is_hidden",                :default => false
    t.integer  "quantity",                 :default => 0
    t.string   "updated_on", :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventories", ["crawl_id"], :name => "index_inventories_on_crawl_id"
  add_index "inventories", ["is_hidden"], :name => "index_inventories_on_is_hidden"
  add_index "inventories", ["product_id", "store_id"], :name => "index_inventories_on_product_id_and_store_id", :unique => true

  create_table "inventory_revisions", :force => true do |t|
    t.integer "inventory_id"
    t.integer "quantity",                   :default => 0
    t.string  "updated_on",   :limit => 10
  end

  add_index "inventory_revisions", ["updated_on"], :name => "index_inventory_revisions_on_updated_on"

  create_table "product_revisions", :force => true do |t|
    t.integer  "crawl_id"
    t.integer  "product_id"
    t.boolean  "is_hidden"
    t.boolean  "is_discontinued"
    t.integer  "price_in_cents",                                    :default => 0
    t.integer  "regular_price_in_cents",                            :default => 0
    t.integer  "limited_time_offer_savings_in_cents",               :default => 0
    t.string   "limited_time_offer_ends_on",          :limit => 10
    t.integer  "bonus_reward_miles",                                :default => 0
    t.string   "bonus_reward_miles_ends_on",          :limit => 10
    t.integer  "inventory_count",                                   :default => 0
    t.integer  "inventory_volume_in_milliliters",                   :default => 0
    t.integer  "inventory_price_in_cents",                          :default => 0
    t.boolean  "has_limited_time_offer",                            :default => false
    t.boolean  "has_bonus_reward_miles",                            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_revisions", ["product_id", "crawl_id"], :name => "index_product_revisions_on_product_id_and_crawl_id"

  create_table "products", :force => true do |t|
    t.integer  "crawl_id"
    t.boolean  "is_hidden",                                          :default => false
    t.string   "name",                                :limit => 100
    t.boolean  "is_discontinued",                                    :default => false
    t.integer  "price_in_cents",                                     :default => 0
    t.integer  "regular_price_in_cents",                             :default => 0
    t.integer  "limited_time_offer_savings_in_cents",                :default => 0
    t.string   "limited_time_offer_ends_on",          :limit => 10
    t.integer  "bonus_reward_miles",                                 :default => 0
    t.string   "bonus_reward_miles_ends_on",          :limit => 10
    t.string   "stock_type",                          :limit => 10
    t.string   "primary_category",                    :limit => 32
    t.string   "secondary_category",                  :limit => 32
    t.string   "origin",                              :limit => 60
    t.string   "package",                             :limit => 32
    t.string   "package_unit_type",                   :limit => 20
    t.integer  "package_unit_volume_in_milliliters",                 :default => 0
    t.integer  "total_package_units",                                :default => 0
    t.integer  "total_package_volume_in_milliliters",                :default => 0
    t.integer  "volume_in_milliliters",                              :default => 0
    t.integer  "alcohol_content",                                    :default => 0
    t.integer  "price_per_liter_of_alcohol_in_cents",                :default => 0
    t.integer  "price_per_liter_in_cents",                           :default => 0
    t.integer  "inventory_count",                                    :default => 0
    t.integer  "inventory_volume_in_milliliters",                    :default => 0
    t.integer  "inventory_price_in_cents",                           :default => 0
    t.string   "sugar_content",                       :limit => 3
    t.string   "producer_name",                       :limit => 80
    t.string   "released_on",                         :limit => 10
    t.boolean  "has_limited_time_offer",                             :default => false
    t.boolean  "has_bonus_reward_miles",                             :default => false
    t.boolean  "is_seasonal",                                        :default => false
    t.boolean  "is_vqa",                                             :default => false
    t.text     "description"
    t.text     "serving_suggestion"
    t.text     "tasting_note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["crawl_id"], :name => "index_products_on_crawl_id"
  add_index "products", ["inventory_count"], :name => "index_products_on_inventory_count"
  add_index "products", ["is_discontinued"], :name => "index_products_on_is_discontinued"
  add_index "products", ["updated_at"], :name => "index_products_on_updated_at"

  create_table "store_revisions", :force => true do |t|
    t.integer  "crawl_id"
    t.integer  "store_id"
    t.boolean  "is_hidden"
    t.integer  "products_count"
    t.integer  "inventory_count"
    t.integer  "inventory_price_in_cents"
    t.integer  "inventory_volume_in_milliliters"
    t.integer  "sunday_open"
    t.integer  "sunday_close"
    t.integer  "monday_open"
    t.integer  "monday_close"
    t.integer  "tuesday_open"
    t.integer  "tuesday_close"
    t.integer  "wednesday_open"
    t.integer  "wednesday_close"
    t.integer  "thursday_open"
    t.integer  "thursday_close"
    t.integer  "friday_open"
    t.integer  "friday_close"
    t.integer  "saturday_open"
    t.integer  "saturday_close"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "store_revisions", ["store_id", "crawl_id"], :name => "index_store_revisions_on_store_id_and_crawl_id", :unique => true

  create_table "stores", :force => true do |t|
    t.integer  "crawl_id"
    t.boolean  "is_hidden",                                      :default => false
    t.string   "name",                            :limit => 50
    t.string   "address_line_1",                  :limit => 40
    t.string   "address_line_2",                  :limit => 40
    t.string   "city",                            :limit => 25
    t.string   "postal_code",                     :limit => 6
    t.string   "telephone",                       :limit => 14
    t.string   "fax",                             :limit => 14
    t.integer  "products_count",                                 :default => 0
    t.integer  "inventory_count",                                :default => 0
    t.integer  "inventory_price_in_cents",                       :default => 0
    t.integer  "inventory_volume_in_milliliters",                :default => 0
    t.boolean  "has_wheelchair_accessability",                   :default => false
    t.boolean  "has_bilingual_services",                         :default => false
    t.boolean  "has_product_consultant",                         :default => false
    t.boolean  "has_tasting_bar",                                :default => false
    t.boolean  "has_beer_cold_room",                             :default => false
    t.boolean  "has_special_occasion_permits",                   :default => false
    t.boolean  "has_vintages_corner",                            :default => false
    t.boolean  "has_parking",                                    :default => false
    t.boolean  "has_transit_access",                             :default => false
    t.integer  "sunday_open"
    t.integer  "sunday_close"
    t.integer  "monday_open"
    t.integer  "monday_close"
    t.integer  "tuesday_open"
    t.integer  "tuesday_close"
    t.integer  "wednesday_open"
    t.integer  "wednesday_close"
    t.integer  "thursday_open"
    t.integer  "thursday_close"
    t.integer  "friday_open"
    t.integer  "friday_close"
    t.integer  "saturday_open"
    t.integer  "saturday_close"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.point    "geo",                             :limit => nil,                    :null => false, :srid => 4326
  end

  add_index "stores", ["geo"], :name => "index_stores_on_geo", :spatial => true
  add_index "stores", ["is_hidden"], :name => "index_stores_on_is_hidden"

end
