class RemoveCrawlIdConstraintFromCrawlEvents < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE crawl_events DROP CONSTRAINT crawl_events_crawl_id_fkey'
  end
end
