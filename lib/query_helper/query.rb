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
    end

    def self.per_page
      20
    end

    def self.csv_limit
      500
    end

    def self.table
      raise NotImplementedError, "#{self}#table needs to be implmented"
    end

    def self.filterable_fields
      []
    end

    def self.sortable_fields
      []
    end

    def self.order
      raise NotImplementedError, "#{self}#order needs to be implmented"
    end

    def self.where
      []
    end

    def self.where_not
      []
    end

    def self.order_expr(term)
      field, ord = term.split('.').map { |v| v.to_s.downcase.strip }
      unless sortable_fields.include?(field)
        raise BadQueryError, "A value supplied for the order parameter " \
        "(#{term}) is not valid. It contains a field (#{field}) that is " \
        "not sortable. It must be one of: " \
        "#{sortable_fields.join(', ')}."
      end
      unless ['desc', 'asc', nil].include?(ord)
        raise BadQueryError, "A value supplied for the order parameter " \
        "(#{term}) is not valid. It contains an invalid sort order " \
        "(#{ord}) for (#{field}) try using: #{field}.desc or #{field}.asc " \
        "instead."
      end
      case ord
      when 'asc'
        :"#{table}__#{field}".asc(:nulls => :last)
      when 'desc', nil
        :"#{table}__#{field}".desc(:nulls => :last)
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
      Hash[where.map { |w| [:"#{self.class.table}__#{w}", true ] }].
        merge(Hash[where_not.map { |w| [:"#{self.class.table}__#{w}", false] }])
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

    def page
      @page || 1
    end

    def per_page=(value)
      unless (MIN_PER_PAGE..MAX_PER_PAGE).include?(value.to_i)
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

    def page_dataset
      @page_dataset ||= dataset.paginate(page, per_page)
    end

    def csv_dataset
      @csv_dataset ||= dataset.limit(self.class.csv_limit)
    end

    def db
      @db ||= DB[self.class.table]
    end

    def path_for_page(page_num)
      q = request.fullpath.dup
      case
      when !page_num
        nil
      when q.include?('page=')
        q.sub(/page=[0-9]+/, "page=#{page_num}")
      when q.include?('?')
        q + "&page=#{page_num}"
      else
        q + "?page=#{page_num}"
      end
    end

    def pager
      { :current_page => :current_page,
        :next_page    => :next_page,
        :prev_page    => :previous_page,
        :page_count   => :final_page
      }.reduce(
        :records_per_page => per_page,
        :total_record_count => page_dataset.pagination_record_count,
        :current_page_record_count => page_dataset.current_page_record_count,
        :is_first_page => page_dataset.first_page?,
        :is_final_page => page_dataset.last_page?
      ) do |hsh, (meth, key)|
        num = page_dataset.send(meth)
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

    def as_csv
      []
    end

    protected

    def validate
      return unless where && where_not
      same = where.select { |w| where_not.include?(w) }
      if same.any?
        raise BadQueryError, "One or more of the values supplied for the " \
        "where parameter matches one or more of the values supplied for the " \
        "where_not parameter: #{same.join(', ')}. These parameters can only " \
        "contain indifferent values."
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
