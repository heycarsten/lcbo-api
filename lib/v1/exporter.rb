module V1
  class Exporter
    TABLES = [:stores, :products, :inventories]

    DUMP_COLS = {
      inventories: [
        :product_id,
        :store_id,
        :is_dead,
        :quantity,
        :reported_on,
        :updated_at
      ],

      products: [
        :id,
        :is_dead,
        :name,
        :tags,
        :is_discontinued,
        :price_in_cents,
        :regular_price_in_cents,
        :limited_time_offer_savings_in_cents,
        :limited_time_offer_ends_on,
        :bonus_reward_miles,
        :bonus_reward_miles_ends_on,
        :stock_type,
        :primary_category,
        :secondary_category,
        :origin,
        :package,
        :package_unit_type,
        :package_unit_volume_in_milliliters,
        :total_package_units,
        :volume_in_milliliters,
        :alcohol_content,
        :price_per_liter_of_alcohol_in_cents,
        :price_per_liter_in_cents,
        :inventory_count,
        :inventory_volume_in_milliliters,
        :inventory_price_in_cents,
        :sugar_content,
        :producer_name,
        :released_on,
        :has_value_added_promotion,
        :has_limited_time_offer,
        :has_bonus_reward_miles,
        :is_seasonal,
        :is_vqa,
        :is_kosher,
        :value_added_promotion_description,
        :description,
        :serving_suggestion,
        :tasting_note,
        :updated_at,
        :image_thumb_url,
        :image_url,
        :varietal,
        :style,
        :tertiary_category,
        :sugar_in_grams_per_liter
      ],

      stores: [
        :id,
        :is_dead,
        :name,
        :tags,
        :address_line_1,
        :address_line_2,
        :city,
        :postal_code,
        :telephone,
        :fax,
        :latitude,
        :longitude,
        :products_count,
        :inventory_count,
        :inventory_price_in_cents,
        :inventory_volume_in_milliliters,
        :has_wheelchair_accessability,
        :has_bilingual_services,
        :has_product_consultant,
        :has_tasting_bar,
        :has_beer_cold_room,
        :has_special_occasion_permits,
        :has_vintages_corner,
        :has_parking,
        :has_transit_access,
        :sunday_open,
        :sunday_close,
        :monday_open,
        :monday_close,
        :tuesday_open,
        :tuesday_close,
        :wednesday_open,
        :wednesday_close,
        :thursday_open,
        :thursday_close,
        :friday_open,
        :friday_close,
        :saturday_open,
        :saturday_close,
        :updated_at
      ]
    }

    def initialize(key)
      AWS::S3::Base.establish_connection!(
        access_key_id:     Rails.application.secrets.s3_access_key,
        secret_access_key: Rails.application.secrets.s3_secret_key)

      @key = key
      @s3  = AWS::S3::S3Object
      @dir = File.join(Dir.tmpdir, 'lcboapi-tmp')

      `mkdir -p #{@dir} && chmod 0777 #{@dir}`

      @zip = File.join(@dir, Time.now.strftime('lcbo-%Y%m%d.zip'))
    end

    def self.run(key)
      new(key).run
    end

    def run
      copy_tables
      make_archive
      upload_archive
      cleanup
    end

    def copy_tables
      copy :stores
      copy :products
      copy :inventories
    end

    def make_archive
      files = TABLES.map { |t| csv_file(t) }.join(' ')
      `zip -j #{@zip} #{files}`
    end

    def upload_archive
      @s3.store("datasets/#{@key}.zip", open(@zip), Rails.application.secrets.s3_bucket,
        content_type: 'application/zip',
        access:       :public_read
      )
    end

    def cleanup
      `rm -rf #{@dir}`
    end

    private

    def csv_file(table)
      File.join(@dir, "#{table}.csv")
    end

    def copy(table)
      db_name = ActiveRecord::Base.connection.current_database
      cols    = DUMP_COLS[table].join(', ')
      sql     = "COPY #{table} (#{cols}) TO STDOUT DELIMITER ',' CSV HEADER"

      `psql -d #{db_name} -o #{csv_file(table)} -c "#{sql}"`
    end
  end
end
