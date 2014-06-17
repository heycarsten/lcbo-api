# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140616233032) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "fuzzystrmatch"
  enable_extension "hstore"
  enable_extension "pg_trgm"
  enable_extension "tsearch2"
  enable_extension "unaccent"

  create_table "crawl_events", force: true do |t|
    t.integer  "crawl_id"
    t.string   "level",      limit: 25
    t.text     "message"
    t.text     "payload"
    t.datetime "created_at",            null: false
  end

  add_index "crawl_events", ["crawl_id", "created_at"], name: "crawl_events_crawl_id_created_at_index", using: :btree

  create_table "crawls", force: true do |t|
    t.integer  "crawl_event_id"
    t.string   "state",                                         limit: 20
    t.string   "task",                                          limit: 60
    t.integer  "total_products",                                           default: 0
    t.integer  "total_stores",                                             default: 0
    t.integer  "total_inventories",                                        default: 0
    t.integer  "total_product_inventory_count",                 limit: 8,  default: 0
    t.integer  "total_product_inventory_volume_in_milliliters", limit: 8,  default: 0
    t.integer  "total_product_inventory_price_in_cents",        limit: 8,  default: 0
    t.integer  "total_jobs",                                               default: 0
    t.integer  "total_finished_jobs",                                      default: 0
    t.text     "store_ids"
    t.text     "product_ids"
    t.text     "added_product_ids"
    t.text     "added_store_ids"
    t.text     "removed_product_ids"
    t.text     "removed_store_ids"
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
  end

  add_index "crawls", ["created_at"], name: "crawls_created_at_index", using: :btree
  add_index "crawls", ["state"], name: "crawls_state_index", using: :btree
  add_index "crawls", ["total_inventories"], name: "crawls_total_inventories_index", using: :btree
  add_index "crawls", ["total_product_inventory_count"], name: "crawls_total_product_inventory_count_index", using: :btree
  add_index "crawls", ["total_product_inventory_price_in_cents"], name: "crawls_total_product_inventory_price_in_cents_index", using: :btree
  add_index "crawls", ["total_product_inventory_volume_in_milliliters"], name: "crawls_total_product_inventory_volume_in_milliliters_index", using: :btree
  add_index "crawls", ["total_products"], name: "crawls_total_products_index", using: :btree
  add_index "crawls", ["total_stores"], name: "crawls_total_stores_index", using: :btree
  add_index "crawls", ["updated_at"], name: "crawls_updated_at_index", using: :btree

  create_table "inventories", force: true do |t|
    t.integer  "product_id",                 null: false
    t.integer  "store_id",                   null: false
    t.integer  "crawl_id"
    t.boolean  "is_dead",    default: false
    t.integer  "quantity",   default: 0
    t.date     "updated_on"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "inventories", ["is_dead"], name: "inventories_is_dead_index", using: :btree
  add_index "inventories", ["product_id", "store_id"], name: "index_inventories_on_product_id_and_store_id", using: :btree
  add_index "inventories", ["product_id"], name: "index_inventories_on_product_id", using: :btree
  add_index "inventories", ["store_id"], name: "index_inventories_on_store_id", using: :btree

  create_table "products", force: true do |t|
    t.integer  "crawl_id"
    t.boolean  "is_dead",                                         default: false
    t.string   "name",                                limit: 100
    t.string   "tags",                                limit: 380
    t.boolean  "is_discontinued",                                 default: false
    t.integer  "price_in_cents",                                  default: 0
    t.integer  "regular_price_in_cents",                          default: 0
    t.integer  "limited_time_offer_savings_in_cents",             default: 0
    t.date     "limited_time_offer_ends_on"
    t.integer  "bonus_reward_miles",                  limit: 2,   default: 0
    t.date     "bonus_reward_miles_ends_on"
    t.string   "stock_type",                          limit: 10
    t.string   "primary_category",                    limit: 60
    t.string   "secondary_category",                  limit: 60
    t.string   "origin",                              limit: 60
    t.string   "package",                             limit: 32
    t.string   "package_unit_type",                   limit: 20
    t.integer  "package_unit_volume_in_milliliters",  limit: 2,   default: 0
    t.integer  "total_package_units",                 limit: 2,   default: 0
    t.integer  "total_package_volume_in_milliliters",             default: 0
    t.integer  "volume_in_milliliters",                           default: 0
    t.integer  "alcohol_content",                     limit: 2,   default: 0
    t.integer  "price_per_liter_of_alcohol_in_cents",             default: 0
    t.integer  "price_per_liter_in_cents",                        default: 0
    t.integer  "inventory_count",                     limit: 8,   default: 0
    t.integer  "inventory_volume_in_milliliters",     limit: 8,   default: 0
    t.integer  "inventory_price_in_cents",            limit: 8,   default: 0
    t.string   "sugar_content",                       limit: 100
    t.string   "producer_name",                       limit: 80
    t.date     "released_on"
    t.boolean  "has_value_added_promotion",                       default: false
    t.boolean  "has_limited_time_offer",                          default: false
    t.boolean  "has_bonus_reward_miles",                          default: false
    t.boolean  "is_seasonal",                                     default: false
    t.boolean  "is_vqa",                                          default: false
    t.boolean  "is_kosher",                                       default: false
    t.text     "value_added_promotion_description"
    t.text     "description"
    t.text     "serving_suggestion"
    t.text     "tasting_note"
    t.datetime "updated_at",                                                      null: false
    t.datetime "created_at",                                                      null: false
    t.string   "image_thumb_url",                     limit: 100
    t.string   "image_url",                           limit: 100
    t.string   "varietal",                            limit: 100
    t.string   "style",                               limit: 100
    t.string   "tertiary_category",                   limit: 60
    t.integer  "sugar_in_grams_per_liter",            limit: 2,   default: 0
    t.integer  "clearance_sale_savings_in_cents",                 default: 0
    t.boolean  "has_clearance_sale",                              default: false
  end

  add_index "products", ["alcohol_content"], name: "products_alcohol_content_index", using: :btree
  add_index "products", ["bonus_reward_miles"], name: "products_bonus_reward_miles_index", using: :btree
  add_index "products", ["bonus_reward_miles_ends_on"], name: "products_bonus_reward_miles_ends_on_index", using: :btree
  add_index "products", ["clearance_sale_savings_in_cents"], name: "products_clearance_sale_savings_in_cents_index", using: :btree
  add_index "products", ["created_at"], name: "products_created_at_index", using: :btree
  add_index "products", ["has_value_added_promotion", "has_limited_time_offer", "has_bonus_reward_miles", "is_seasonal", "is_vqa", "is_kosher"], name: "products_has_value_added_promotion_has_limited_time_offer_has_b", using: :btree
  add_index "products", ["inventory_count"], name: "products_inventory_count_index", using: :btree
  add_index "products", ["inventory_price_in_cents"], name: "products_inventory_price_in_cents_index", using: :btree
  add_index "products", ["inventory_volume_in_milliliters"], name: "products_inventory_volume_in_milliliters_index", using: :btree
  add_index "products", ["is_dead"], name: "products_is_dead_index", using: :btree
  add_index "products", ["is_discontinued"], name: "products_is_discontinued_index", using: :btree
  add_index "products", ["limited_time_offer_ends_on"], name: "products_limited_time_offer_ends_on_index", using: :btree
  add_index "products", ["limited_time_offer_savings_in_cents"], name: "products_limited_time_offer_savings_in_cents_index", using: :btree
  add_index "products", ["package_unit_volume_in_milliliters"], name: "products_package_unit_volume_in_milliliters_index", using: :btree
  add_index "products", ["price_in_cents"], name: "products_price_in_cents_index", using: :btree
  add_index "products", ["price_per_liter_in_cents"], name: "products_price_per_liter_in_cents_index", using: :btree
  add_index "products", ["price_per_liter_of_alcohol_in_cents"], name: "products_price_per_liter_of_alcohol_in_cents_index", using: :btree
  add_index "products", ["primary_category"], name: "products_primary_category_index", using: :btree
  add_index "products", ["regular_price_in_cents"], name: "products_regular_price_in_cents_index", using: :btree
  add_index "products", ["released_on"], name: "products_released_on_index", using: :btree
  add_index "products", ["secondary_category"], name: "products_secondary_category_index", using: :btree
  add_index "products", ["stock_type"], name: "products_stock_type_index", using: :btree
  add_index "products", ["style"], name: "products_style_index", using: :btree
  add_index "products", ["sugar_in_grams_per_liter"], name: "products_sugar_in_grams_per_liter_index", using: :btree
  add_index "products", ["tertiary_category"], name: "products_tertiary_category_index", using: :btree
  add_index "products", ["updated_at"], name: "products_updated_at_index", using: :btree
  add_index "products", ["varietal"], name: "products_varietal_index", using: :btree
  add_index "products", ["volume_in_milliliters"], name: "products_volume_in_milliliters_index", using: :btree

  create_table "stores", force: true do |t|
    t.integer  "crawl_id"
    t.boolean  "is_dead",                                     default: false
    t.string   "name",                            limit: 50
    t.string   "tags",                            limit: 380
    t.string   "address_line_1",                  limit: 40
    t.string   "address_line_2",                  limit: 40
    t.string   "city",                            limit: 25
    t.string   "postal_code",                     limit: 6
    t.string   "telephone",                       limit: 14
    t.string   "fax",                             limit: 14
    t.float    "latitude",                                                    null: false
    t.float    "longitude",                                                   null: false
    t.float    "latrad",                                                      null: false
    t.float    "lngrad",                                                      null: false
    t.integer  "products_count",                              default: 0
    t.integer  "inventory_count",                 limit: 8,   default: 0
    t.integer  "inventory_price_in_cents",        limit: 8,   default: 0
    t.integer  "inventory_volume_in_milliliters", limit: 8,   default: 0
    t.boolean  "has_wheelchair_accessability",                default: false
    t.boolean  "has_bilingual_services",                      default: false
    t.boolean  "has_product_consultant",                      default: false
    t.boolean  "has_tasting_bar",                             default: false
    t.boolean  "has_beer_cold_room",                          default: false
    t.boolean  "has_special_occasion_permits",                default: false
    t.boolean  "has_vintages_corner",                         default: false
    t.boolean  "has_parking",                                 default: false
    t.boolean  "has_transit_access",                          default: false
    t.integer  "sunday_open",                     limit: 2
    t.integer  "sunday_close",                    limit: 2
    t.integer  "monday_open",                     limit: 2
    t.integer  "monday_close",                    limit: 2
    t.integer  "tuesday_open",                    limit: 2
    t.integer  "tuesday_close",                   limit: 2
    t.integer  "wednesday_open",                  limit: 2
    t.integer  "wednesday_close",                 limit: 2
    t.integer  "thursday_open",                   limit: 2
    t.integer  "thursday_close",                  limit: 2
    t.integer  "friday_open",                     limit: 2
    t.integer  "friday_close",                    limit: 2
    t.integer  "saturday_open",                   limit: 2
    t.integer  "saturday_close",                  limit: 2
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  add_index "stores", ["created_at"], name: "stores_created_at_index", using: :btree
  add_index "stores", ["has_wheelchair_accessability", "has_bilingual_services", "has_product_consultant", "has_tasting_bar", "has_beer_cold_room", "has_special_occasion_permits", "has_vintages_corner", "has_parking", "has_transit_access"], name: "stores_has_wheelchair_accessability_has_bilingual_services_has_", using: :btree
  add_index "stores", ["inventory_count"], name: "stores_inventory_count_index", using: :btree
  add_index "stores", ["inventory_price_in_cents"], name: "stores_inventory_price_in_cents_index", using: :btree
  add_index "stores", ["inventory_volume_in_milliliters"], name: "stores_inventory_volume_in_milliliters_index", using: :btree
  add_index "stores", ["is_dead"], name: "stores_is_dead_index", using: :btree
  add_index "stores", ["products_count"], name: "stores_products_count_index", using: :btree
  add_index "stores", ["updated_at"], name: "stores_updated_at_index", using: :btree

end
