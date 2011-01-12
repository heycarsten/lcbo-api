# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module DatabaseHelpers
  def clean_database
    DB.tables.
      reject { |table| table == :schema_info }.
      each   { |table| DB[table].delete }
  end
end

module FactoryHelpers
  def RevisionFactory(type, model_instance, opts = {})
    db = {
      :store => DB[:store_revisions],
      :product => DB[:product_revisions],
      :inventory => DB[:inventory_revisions]
    }[type]
    cols = db.columns
    data = model_instance.as_json.slice(*cols)
    if [:store, :product].include?(type)
      data[:"#{type}_id"] = model_instance.id
      data[:crawl_id]     = opts.delete(:crawl_id) || Fabricate(:crawl).id
    else
      data[:updated_on] = opts.delete(:updated_on) || Date.new(2010, 10, 10)
    end
    db.insert(data.merge(opts))
  end
end

class ActionDispatch::TestResponse
  def jsonp?
    'text/javascript' == content_type
  end

  def json?
    'application/json' == content_type
  end

  def csv?
    'text/csv' == content_type
  end

  def tsv?
    'text/tsv' == content_type
  end

  def tsv
    @tsv ||= parse_tsv
  end

  def csv
    @csv ||= parse_csv
  end

  def jsonp
    @jsonp ||= parse_jsonp
  end

  def json
    @json ||= parse_json
  end

  private

  def parse_csv
    raise "Not a CSV response: #{content_type}" unless csv?
    CSV.parse(body)
  end

  def parse_tsv
    raise "Not a TSV response: #{content_type}" unless tsv?
    CSV.parse(body, :col_sep => "\t")
  end

  def parse_json
    raise "Not a JSON response: #{content_type}" unless json?
    Yajl::Parser.parse(body, :symbolize_keys => true)
  end

  def parse_jsonp
    raise "Not a JSON-P response: #{content_type}" unless jsonp?
    json = body.scan(/\A[a-z0-9_]+\((.+)\)\;\Z/mi)[0][0]
    Yajl::Parser.parse(json, :symbolize_keys => true)
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.include(DatabaseHelpers)
  config.include(FactoryHelpers)
end

shared_examples_for 'a JSON 404 error' do
  it 'returns a properly formed JSON error response' do
    response.status.should == 404
    response.should be_json
    response.json.should be_a Hash
    response.json[:error].should == 'not_found_error'
    response.json[:message].should be_a String
    response.json.keys.should include :result
    response.json[:status].should == 404
  end
end

shared_examples_for 'a JSON 400 error' do
  it 'returns a properly formed JSON error response' do
    response.status.should == 400
    response.should be_json
    response.json.should be_a Hash
    response.json[:error].should be_a String
    response.json[:message].should be_a String
    response.json.keys.should include :result
    response.json[:status].should == 400
  end
end

shared_examples_for 'a JSON response' do
  it 'returns a properly formed JSON response' do
    response.status.should == 200
    response.should be_json
    response.json.should be_a Hash
    response.json.keys.should_not include :error
    response.json.keys.should include :message
    response.json.keys.should include :result
    response.json[:status].should == 200
  end
end

shared_examples_for 'a JSON-P response' do
  it 'returns a properly formed JSON response' do
    response.status.should == 200
    response.should be_jsonp
    response.jsonp.should be_a Hash
    response.jsonp[:status].should == 200
  end
end

shared_examples_for 'a TSV response' do
  it 'returns a properly formed TSV response' do
    response.status.should == 200
    response.should be_tsv
    response.tsv.should be_a Array
    response.tsv.first.should be_a Array
    response.tsv.first.size.should > 1
  end
end

shared_examples_for 'a CSV response' do
  it 'returns a properly formed CSV response' do
    response.status.should == 200
    response.should be_csv
    response.csv.should be_a Array
    response.csv.first.should be_a Array
    response.csv.first.size.should > 1
  end
end