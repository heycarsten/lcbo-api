require 'rails_helper'

RSpec.describe Crawl, 'with nil store_nos and product_nos', type: :model do
  let(:crawl) { Fabricate(:crawl, product_ids: nil, store_ids: nil) }

  it 'should exist' do
    expect(crawl).to be_persisted
  end

  it 'should be serializable' do
    payload = V1::QueryHelper::DatasetsQuery.serialize(crawl)
    expect(payload[:product_ids]).to eq []
    expect(payload[:store_ids]).to eq []
  end
end
