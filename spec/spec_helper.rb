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

class ActionDispatch::TestResponse
  def json?
    %w[ application/json text/json ].include?(content_type)
  end

  def json
    @json ||= parse_json
  end

  private

  def parse_json
    raise "Not a JSON response: #{content_type}" unless json?
    Yajl::Parser.parse(body, :symbolize_keys => true)
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.include(DatabaseHelpers)
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
