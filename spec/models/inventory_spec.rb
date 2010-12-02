# == Schema Information
#
# Table name: inventories
#
#  id         :integer         not null
#  product_id :integer
#  store_id   :integer
#  crawl_id   :integer
#  is_hidden  :boolean         default(FALSE)
#  quantity   :integer         default(0)
#  updated_on :string(10)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_inventories_on_crawl_id                 (crawl_id)
#  index_inventories_on_is_hidden                (is_hidden)
#  index_inventories_on_product_id_and_store_id  (product_id,store_id) UNIQUE
#

require 'spec_helper'

describe Inventory do
end

