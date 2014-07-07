module V1
  module QueryHelper
    class Query
      attr_accessor :request, :params, :page, :per_page, :q

      def initialize(request, params)
        self.params    = params
        self.request   = request
        self.page      = params[:page]      if params[:page].present?
        self.per_page  = params[:per_page]  if params[:per_page].present?
        self.order     = params[:order]     if params[:order].present?
        self.where     = params[:where]     if params[:where].present?
        self.where_not = params[:where_not] if params[:where_not].present?
        self.limit     = params[:limit]     if params[:limit].present?
      end

      def self.per_page
        20
      end

      def self.max_per_page
        100
      end

      def self.limit
        50
      end

      def self.max_limit
        500
      end

      def self.humanize_csv_columns(cols)
        cols.map { |c| c.to_s.gsub('_', ' ').titlecase }
      end

      def self.serialize(record, opts = {})
        serializer.new(record, opts).as_json(root: false)
      end

      def self.table
        @table ||= model.table_name.to_sym
      end

      def self.serializer
        @serializer ||= "API::V1::#{model.to_s}Serializer".constantize
      end

      def self.model_name
        to_s.demodulize.sub('Query', '').underscore.singularize
      end

      def self.model
        @model ||= model_name.to_s.classify.constantize
      end

      def self.filterable_fields
        []
      end

      def self.sortable_fields
        []
      end

      def self.order
        raise NotImplementedError, "#{self}#order needs to be implemented."
      end

      def self.where
        []
      end

      def self.where_not
        []
      end

      def self.sortable_field_names
        @sortable_fields_names ||= if sortable_fields.is_a?(Array)
          sortable_fields
        else
          sortable_fields.keys.map(&:to_s)
        end
      end

      def self.sortable_column_for_field(field)
        return field.to_s unless sortable_fields.is_a?(Hash)

        sortable_fields[field.to_sym].to_s
      end

      def self.order_expr(term)
        field, ord = term.split('.').map { |v| v.to_s.downcase.strip }

        unless sortable_field_names.include?(field)
          raise BadQueryError, "A value supplied for the order parameter " \
          "(#{term}) is not valid. It contains a field (#{field}) that is " \
          "not sortable. It must be one of: " \
          "#{sortable_field_names.join(', ')}."
        end

        unless ['desc', 'asc', nil].include?(ord)
          raise BadQueryError, "A value supplied for the order parameter " \
          "(#{term}) is not valid. It contains an invalid sort order " \
          "(#{ord}) for (#{field}) try using: #{field}.desc or #{field}.asc " \
          "instead."
        end

        col = sortable_column_for_field(field)

        case ord
        when 'asc'
          %{#{table}.#{col} ASC NULLS LAST}
        when 'desc', nil
          %{#{table}.#{col} DESC NULLS LAST}
        end
      end

      def where=(value)
        return unless self.class.filterable_fields.any?
        @where = split_filter_list(:where, value)
      end

      def where
        @where || self.class.where.reject { |w| where_not.include?(w) }
      end

      def where_not=(value)
        return unless self.class.filterable_fields.any?
        @where_not = split_filter_list(:where_not, value)
      end

      def where_not
        @where_not || self.class.where_not.reject { |w| where.include?(w) }
      end

      def filter_hash
        Hash[where.map     { |w| ["#{self.class.table}.#{w}", true]  }].merge(
        Hash[where_not.map { |w| ["#{self.class.table}.#{w}", false] }])
      end

      def limit=(value)
        unless (1..self.class.max_limit).include?(value.to_i)
          raise BadQueryError, "The value supplied for the limit parameter " \
          "(#{value}) is not valid. It must be a number between 1 and " \
          "#{self.class.max_limit}."
        end
        @limit = value.to_i
      end

      def limit
        @limit || self.class.limit
      end

      def order=(value)
        return unless self.class.sortable_fields.any?
        @order = split_order_list(value)
      end

      def order
        @order || self.class.order_expr(self.class.order)
      end

      def page=(value)
        unless value.to_i > 0
          raise BadQueryError, "The value suppled for the page parameter" \
          "(#{value}) is not valid. It must be a number greater than zero."
        end
        @page = value.to_i
      end

      def is_csv?
        request.format.csv? || request.format.tsv?
      end

      def page
        @page || 1
      end

      def per_page=(value)
        unless (MIN_PER_PAGE..self.class.max_per_page).include?(value.to_i)
          raise BadQueryError, "The value supplied for the per_page parameter " \
          "(#{value}) is not valid. It must be a number between " \
          "#{MIN_PER_PAGE} and #{MAX_PER_PAGE}."
        end
        @per_page = value.to_i
      end

      def per_page
        @per_page || self.class.per_page
      end

      def has_fulltext?
        q.present?
      end

      def page_scope
        @page_scope ||= scope.page(page).per(per_page)
      end

      def csv_scope
        @csv_scope ||= scope.limit(limit)
      end

      def scope
        model
      end

      def model
        self.class.model
      end

      def serialize(record, opts = {})
        self.class.serialize(record, opts)
      end

      def path_for_page(page_num)
        q = request.fullpath.dup
        case
        when !page_num
          nil
        when q.match(/\&page=[0-9]+/i)
          q.sub(/\&page=[0-9]+/i, "&page=#{page_num}")
        when q.match(/\?page=[0-9]+/i)
          q.sub(/\?page=[0-9]+/i, "?page=#{page_num}")
        when q.include?('?')
          q + "&page=#{page_num}"
        else
          q + "?page=#{page_num}"
        end
      end

      def pager
        { current_page: :current_page,
          next_page:    :next_page,
          prev_page:    :previous_page,
          total_pages:  :total_pages
        }.reduce(
          records_per_page:          page_scope.limit_value,
          total_record_count:        page_scope.total_count,
          current_page_record_count: page_scope.load.size,
          is_first_page:             page_scope.first_page?,
          is_final_page:             page_scope.last_page?
        ) do |hsh, (meth, key)|
          num = page_scope.send(meth)
          hsh.merge(
            key            => num,
            :"#{key}_path" => path_for_page(num)
          )
        end
      end

      def as_json
        h = {}
        h[:pager] = pager
        h
      end

      def as_csv(delimiter = ',')
        records = csv_scope.load
        return '' if records.empty?

        headers = self.class.humanize_csv_columns(
          serialize(records.first, scope: :csv).keys
        )

        CSV.generate(col_sep: delimiter) do |csv|
          csv << headers

          records.each do |record|
            csv << serialize(record, scope: :csv).values
          end
        end
      end

      def as_tsv
        as_csv("\t")
      end

      def format
        request.format.to_s.upcase
      end

      protected

      def validate
        case
        when is_csv? && (params[:per_page].present? || params[:page].present?)
          a = []
          a << 'per_page' if params[:per_page].present?
          a << 'page' if params[:page].present?
          parts = []
          parts << a.join(' and ')
          parts << (a.size == 1 ? 'parameter was' : 'parameters were')
          parts << (a.size == 1 ? 'it' : 'they')
          raise BadQueryError, "The #{parts[0]} #{parts[1]} specified, " \
          "#{parts[2]} can not be used with #{format} responses because " \
          "#{format} formatted responses are not paged."
        when !is_csv? && params[:limit].present?
          raise BadQueryError, "The limit parameter was specified for a " \
          "#{format} response, it can only be used with CSV and TSV response " \
          "formats. If you want to change the number of results that are " \
          "returned per page, use the per_page parameter instead."
        when where && where_not
          same = where.select { |w| where_not.include?(w) }
          if same.any?
            raise BadQueryError, "One or more of the values supplied for the " \
            "where parameter matches one or more of the values supplied for the " \
            "where_not parameter: #{same.join(', ')}. These parameters can only " \
            "contain indifferent values."
          end
        end
      end

      def split_order_list(value)
        @split_order_list ||= {}
        @split_order_list[value] ||= begin
          value.to_s.split(',').map(&:strip).map do |term|
            self.class.order_expr(term)
          end
        end
      end

      def split_filter_list(name, value)
        vals = value.to_s.split(',').map { |v| v.strip.downcase }

        unless vals.all? { |v| self.class.filterable_fields.include?(v) }
          raise BadQueryError, "The value supplied for the #{name} parameter " \
          "(#{value}) is not valid. It must contain one or more of the " \
          "following values separated by commas (,): " \
          "#{self.class.filterable_fields.join(', ')}."
        end

        vals
      end
    end
  end
end
