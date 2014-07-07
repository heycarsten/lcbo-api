module V1
  module QueryHelper
    class Finder
      attr_reader :request, :params

      def initialize(request, params)
        @request = request
        @params = params
      end

      def self.find(*args)
        if (instance = get(*args.map(&:to_i)))
          instance
        else
          raise NotFoundError, "No #{type} exists with id: #{args.join(', ')}."
        end
      end

      def self.type
        to_s.demodulize.sub('Finder', '').downcase
      end

      def self.query
        @query ||= V1::QueryHelper.const_get(:"#{type.classify.pluralize}Query")
      end

      def self.serialize(record, opts = {})
        query.serialize(record, opts)
      end

      def as_json
        { result: self.class.serialize(self.class.find(*as_args)) }
      end

      def as_csv(delimiter = ',')
        record = self.class.find(*as_args)
        json   = self.class.serialize(record, scope: :csv)
        header = self.class.query.humanize_csv_columns(json.keys)

        CSV.generate(col_sep: delimiter) do |csv|
          csv << header
          csv << json.values
        end
      end

      def as_tsv
        as_csv("\t")
      end
    end
  end
end
