# == Schema Information
#
# Table name: crawl_events
#
#  id         :integer         not null, primary key
#  crawl_id   :integer
#  level      :string(25)
#  message    :text
#  payload    :text
#  created_at :datetime
#
# Indexes
#
#  index_crawl_events_on_crawl_id  (crawl_id)
#

class CrawlEvent < ActiveRecord::Base

  belongs_to :crawl

end

