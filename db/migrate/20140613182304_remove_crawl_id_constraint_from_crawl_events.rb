class RemoveCrawlIdConstraintFromCrawlEvents < ActiveRecord::Migration[4.2]
  def up
    execute 'ALTER TABLE crawl_events DROP CONSTRAINT crawl_events_crawl_id_fkey'
  end
end
