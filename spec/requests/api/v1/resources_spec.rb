require 'spec_helper'

describe 'API resource (V1)' do
  describe 'with JS format and no callback' do
    before { get '/datasets.js' }

    it_behaves_like 'a JSON 400 error'

    it 'has a reasonable error message' do
      expect(response.json[:message]).to include('can not be requested without specifying a callback')
    end
  end

  describe 'with JSON format and callback' do
    before { get '/datasets.json?callback=test' }

    it_behaves_like 'a JSON 400 error'

    it 'has a reasonable error message' do
      expect(response.json[:message]).to include('can not be requested with a callback')
    end
  end

  describe 'with default format and callback' do
    before { get '/datasets?callback=test' }

    it 'returns JSON-P' do
      expect(response).to be_jsonp
    end
  end

  describe 'with default format and no callback' do
    before { get '/datasets' }

    it 'returns JSON' do
      expect(response).to be_json
    end
  end

  describe 'with CSV format and callback' do
    before { get '/datasets.csv?callback=test' }

    it 'returns CSV and ignores the callback' do
      expect(response).to be_csv
    end
  end

  describe 'with TSV format and callback' do
    before { get '/datasets.tsv?callback=test' }

    it 'returns TSV and ignores the callback' do
      expect(response).to be_tsv
    end
  end

  describe 'with invalid callback' do
    before { get '/datasets.js?callback=boom-' }

    it_behaves_like 'a JSON 400 error'

    it 'returns JSON' do
      expect(response).to be_json
    end
  end

  describe 'with valid callback and query error' do
    before { get '/datasets.js?callback=test&order=id.boom' }

    it 'returns JSON-P' do
      expect(response).to be_jsonp
    end

    it 'has an HTTP status of 200' do
      expect(response.status).to eq 200
    end

    it 'indicates the actual status in the response object' do
      expect(response.jsonp[:status]).to eq 200
    end
  end

  describe 'requesting a resource as an unsupported format' do
    before { get '/datasets.wsdl' }

    it_behaves_like 'a JSON 404 error'
  end

  describe 'requesting a singular resource as an unsupported format' do
    before { get '/datasets/1.wsdl' }

    it_behaves_like 'a JSON 404 error'
  end

  describe 'getting a singular resource (not found)' do
    before { get '/datasets/dataset+one' }

    it_behaves_like 'a JSON 404 error'
  end
end
