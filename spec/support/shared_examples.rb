shared_examples_for 'a resource' do |options|
  options ||= {}

  def formatted_uri(format = nil, opts = {})
    path, query = subject.split('?')
    q = (query ? query.split('&') : [])
    opts.each { |k, v| q << "#{k}=#{v}" }
    [].tap { |uri|
      uri << (format ? "#{path}.#{format}" : path)
      uri << q.join('&') if q.any?
    }.join('?')
  end

  let(:expected_size) { options[:size] }

  describe 'as JSON (default)' do
    before { get formatted_uri(nil) }

    it 'has the correct HTTP status in the body' do
      expect(response).to be_ok
      expect(response.json[:status]).to eq 200
    end

    it 'is JSON' do
      expect(response).to be_json
      expect(response.json).to be_a Hash
    end

    it 'includes the appropriate nodes' do
      expect(response.json.keys).not_to include(:error)
      expect(response.json.keys).to include(:message)
      expect(response.json.keys).to include(:result)
    end

    it 'is the correct size' do
      expect(response.json[:result].size).to eq(expected_size) if expected_size
    end
  end

  describe 'as JSON' do
    before { get formatted_uri(:json) }

    it 'is JSON' do
      expect(response).to be_json
      expect(response.json).to be_a Hash
    end
  end

  describe 'as CSV' do
    before { get formatted_uri(:csv) }

    it 'is successful' do
      expect(response).to be_ok
    end

    it 'is CSV' do
      expect(response).to be_csv
      expect(response.csv).to be_a Array
    end

    it 'contains a header' do
      expect(response.csv.first).to be_a Array
      expect(response.csv.first.size).to be > 0
    end

    it 'contains at least two rows' do
      expect(response.csv.size).to be > 1
    end

    it 'contains the correct number of rows' do
      expect(response.csv.size - 1).to eq(expected_size) if expected_size
    end
  end

  describe 'as TSV' do
    before { get formatted_uri(:tsv) }

    it 'is successful' do
      expect(response).to be_ok
    end

    it 'is TSV' do
      expect(response).to be_tsv
      expect(response.tsv).to be_a Array
    end

    it 'contains a header' do
      expect(response.tsv.first).to be_a Array
      expect(response.tsv.first.size).to be > 0
    end

    it 'contains at least two rows' do
      expect(response.tsv.size).to be > 1
    end

    it 'contains the correct number of rows' do
      expect(response.tsv.size - 1).to eq expected_size if expected_size
    end
  end

  describe 'as JSON-P (with js extension)' do
    before { get formatted_uri(:js, callback: 'test') }

    it 'is JSON-P' do
      expect(response).to be_jsonp
      expect(response.jsonp).to be_a Hash
    end

    it 'is successful' do
      expect(response).to be_ok
      expect(response.jsonp[:status]).to eq 200
    end

    it 'includes a callback' do
      expect(response.body).to include 'test({'
      expect(response.body).to include '});'
    end
  end

  describe 'as JSON-P (implicit from presence of callback param)' do
    before { get formatted_uri(nil, callback: 'test') }

    it 'is JSON-P' do
      expect(response).to be_jsonp
      expect(response.jsonp).to be_a Hash
    end
  end
end

shared_examples_for 'a JSON 404 error' do
  it 'returns a properly formed JSON error response' do
    expect(response).to be_not_found
    expect(response).to be_json
    expect(response.json).to be_a Hash
    expect(response.json[:error]).to eq 'not_found_error'
    expect(response.json[:message]).to be_a String
    expect(response.json.keys).to include(:result)
    expect(response.json[:status]).to eq 404
  end
end

shared_examples_for 'a JSON 400 error' do
  it 'returns a properly formed JSON error response' do
    expect(response).to be_bad_request
    expect(response).to be_json
    expect(response.json).to be_a Hash
    expect(response.json[:error]).to be_a String
    expect(response.json[:message]).to be_a String
    expect(response.json.keys).to include(:result)
    expect(response.json[:status]).to eq 400
  end
end
