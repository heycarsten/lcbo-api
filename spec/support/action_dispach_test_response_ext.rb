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

  def payload
    @payload ||= if json?
      json
    elsif jsonp?
      jsonp
    elsif csv?
      csv
    elsif tsv?
      tsv
    else
      raise "Not a data response, payload can't be parsed."
    end
  end

  def v1_payload?
    result = payload[:result]
    result.is_a?(Hash) || result.is_a?(Array)
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
    CSV.parse(body, col_sep: "\t")
  end

  def parse_json
    raise "Not a JSON response: #{content_type}" unless json?
    Oj.load(body, symbol_keys: true)
  end

  def parse_jsonp
    raise "Not a JSON-P response: #{content_type}" unless jsonp?
    json = body.scan(/\A[a-z0-9_]+\((.+)\)\;\Z/mi)[0][0]
    Oj.load(json, symbol_keys: true)
  end
end
