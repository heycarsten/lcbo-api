require 'rails_helper'

RSpec.describe Crawl, type: :model do
  let(:crawl) { Crawl.init }

  it 'should exist' do
    expect(crawl).to be_persisted
  end

  it 'should be serializable' do
    payload = V1::QueryHelper::DatasetsQuery.serialize(crawl)
    expect(payload[:product_ids]).to eq []
    expect(payload[:store_ids]).to eq []
  end
end
