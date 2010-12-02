class CreateCrawlEvents < ActiveRecord::Migration

  def self.up
    create_table :crawl_events do |t|
      t.references :crawl
      t.string     :level,      :limit => 25
      t.text       :message
      t.text       :payload
      t.datetime   :created_at
    end
    add_index :crawl_events, :crawl_id
  end

  def self.down
    drop_table :crawl_events
  end

end
