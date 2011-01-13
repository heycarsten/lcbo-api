module QueryHelper
  class Finder

    attr_reader :request, :params

    def initialize(request, params)
      @request = request
      @params = params
    end

    def self.find(*args)
      if (instance = get(*args))
        instance
      else
        raise NotFoundError, "No #{type} exists with id: #{args.join(', ')}."
      end
    end

    def self.type
      to_s.demodulize.sub('Finder', '').downcase
    end

    def as_json
      { :result => self.class.find(*as_args).as_json }
    end

    def as_csv(delimiter = ',')
      rows = self.class.find(*as_args).as_csv(true)
      CSV.generate(:col_sep => delimiter) do |csv|
        rows.each { |row| csv << row }
      end
    end

    def as_tsv
      as_csv("\t")
    end

  end
end
