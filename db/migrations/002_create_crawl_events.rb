Sequel.migration do

  up do
    create_table :crawl_events do
      primary_key :id
      foreign_key :crawl_id, :crawls, :on_delete => :cascade
      string   :level, :size => 25
      text     :message
      text     :payload
      datetime :created_at
    end
  end

  down do
    drop_table :crawl_events
  end

end
