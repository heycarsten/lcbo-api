Sequel.migration do

  up do
    create_table :crawl_events do
      primary_key :id
      foreign_key :crawl_id, :crawls, :on_delete => :cascade
      column :level,      :varchar,   :size => 25
      column :message,    :text
      column :payload,    :text
      column :created_at, :timestamp, :null => false
      index [:crawl_id, :created_at]
    end
  end

  down do
    drop_table :crawl_events
  end

end
