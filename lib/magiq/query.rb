module Magiq
  class Query
    attr_reader :raw_params, :params, :scope, :model, :solo_param

    def self.builder
      @builder ||= Builder.new
    end

    def self.model(&block)
      @model_proc = block
    end

    def self.model_proc
      @model_proc
    end

    def self.scope(&block)
      @scope_proc = block
    end

    def self.scope_proc
      @scope_proc || -> { model.unscoped }
    end

    def self.param(key, opts = {})
      builder.add_param(key, opts)
    end

    def self.apply(*params, &block)
      opts = params.last.is_a?(Hash) ? params.pop : {}
      builder.add_listener(:apply, params, opts, &block)
    end

    def self.check(*params, &block)
      opts = params.last.is_a?(Hash) ? params.pop : {}
      builder.add_listener(:check, params, opts, &block)
    end

    def self.mutual(params, opts = {})
      builder.add_constraint(:mutual, params, opts)
    end

    def self.exclusive(*params)
      builder.add_constraint(:exclusive, params)
    end

    def self.has_pagination(opts = {})
      max_page_size     = opts[:max_page_size] || Magiq[:max_page_size]
      min_page_size     = opts[:min_page_size] || Magiq[:min_page_size]
      default_page_size = opts[:default_page_size] || Magiq[:default_page_size]

      param :page,      type: :whole
      param :page_size, type: :whole

      check :page, :page_size, any: true do |page, page_size|
        if page && page < 1
          bad! "The value provided for `page` must be 1 or greater, but " \
          "#{page.inspect} was provided."
        end

        if page_size && page_size > max_page_size
          bad! "The maximum permitted value for `page_size` is " \
          "#{max_page_size}, but #{page_size.inspect} was provided."
        elsif page_size && page_size < min_page_size
          bad! "The minimum permitted value for `page_size` is " \
          "#{min_page_size}, but #{page_size.inspect} was provided."
        end
      end

      apply do
        next if solo?

        page      = params[:page]
        page_size = params[:page_size] || default_page_size
        new_scope = scope.page(page)

        page_size ? new_scope.per(page_size) : new_scope
      end
    end

    def self.bool(*fields)
      fields.each do |field|
        param(field, type: :bool)
        apply(field) do |val|
          scope.where(field => val)
        end
      end
    end

    def self.order(*fields)
      fields.each do |field|
        p = :"order_#{field}"
        param(p, type: :enum_sort)
        apply(p) do |ord|
          scope.order(field => ord)
        end
      end
    end

    def self.equal(field, opts = {})
      param(field, { solo: true }.merge(opts))

      apply(field) do |val|
        scope.where(field => val)
      end
    end

    def self.range(field, opts = {})
      lt_param  = :"#{field}_lt"
      lte_param = :"#{field}_lte"
      gt_param  = :"#{field}_gt"
      gte_param = :"#{field}_gte"

      param(lt_param,  type: :whole)
      param(lte_param, type: :whole)
      param(gt_param,  type: :whole)
      param(gte_param, type: :whole)

      exclusive(gt_param, gte_param)
      exclusive(lt_param, lte_param)

      check do
        lt_par = if (lt_val = params[lte_param])
          lte_param
        elsif (lt_val = params[lt_param])
          lt_param
        end

        gt_par = if (gt_val = params[gte_param])
          gte_param
        elsif (gt_val = params[gt_param])
          gt_param
        end

        next unless lt_par && gt_par

        if lt_val > gt_val
          bad! "A value of #{lt_val} was provided for `#{lt_par}` but a value " \
          "of #{gt_val} was provided for `#{gt_par}`. The permitted value of  " \
          "`#{lt_par}` must be less than the permitted value provided for " \
          "`#{gt_par}`."
        end

        if lt_val == gt_val
          bad! "The same value of #{gt_val} was provided for both `#{lt_par}` " \
          "and #{gt_par}. The permitted value of `#{lt_par}` must be " \
          "less than the permitted value provided for `#{gt_par}`."
        end
      end

      apply(gt_param) do |val|
        scope.where(model.arel_table[field].gt(val))
      end

      apply(lt_param) do |val|
        scope.where(model.arel_table[field].lt(val))
      end

      apply(gte_param) do |val|
        scope.where(model.arel_table[field].gte(val))
      end

      apply(lte_param) do |val|
        scope.where(model.arel_table[field].lte(val))
      end
    end

    def initialize(params)
      @raw_params = params
      @listeners  = {}
    end

    def builder
      self.class.builder
    end

    def update_scope!(new_scope)
      return unless new_scope
      @scope = new_scope
    end

    def extract!
      @params = {}

      raw_params.each_pair do |raw_key, raw_value|
        key = raw_key.to_sym

        next unless (param = builder.params[key])

        begin
          next unless (value = param.extract(raw_value))
          @params[param.key] = value
        rescue BadParamError => e
          raise BadParamError, "The `#{param.key}` parameter is invalid: " \
          "#{e.message}"
        end
      end

      @params.keys.each do |p|
        next unless (found = builder.params[p])
        next unless found.solo?

        if @params.size > 1
          raise BadParamError, "The `#{found.key}` parameter can only be used " \
          "by itself in a query."
        else
          @has_solo_param = true
          @solo_param = found
        end
      end
    end

    def verify!
      if !@params
        raise RuntimeError, "verify! was called before extract!"
      end

      builder.constraints.each do |(op, keys, opts)|
        case op
        when :exclusive
          found_keys = keys.select { |k| params.key?(k) }

          next if found_keys.empty? || found_keys.one?

          raise ParamsError, "The following parameters are not permitted " \
          "to be provided together: #{found_keys.join(', ')}"
        when :mutual
          exclusives = opts[:exclusive] && Array(opts[:exclusive]) || []
          found_keys = keys.select { |k| params.key?(k) }
          found_excl = exclusives.select { |k| params.key?(k) }

          next if found_keys.empty?
          next if found_keys.empty? && found_excl.empty?
          next if found_keys == keys && found_excl.empty?

          if found_excl.any?
            raise ParamsError, "The provided " \
            "parameter#{found_keys.one? ? '' : 's'}: " \
            "#{found_keys.map { |k| "`#{k}`" }.join(', ')} " \
            "#{found_keys.one? ? 'is' : 'are'} mutually exclusive to: " \
            "#{found_excl.map { |k| "`#{k}`" }.join ', '}."
          end

          raise ParamsError, "The provided " \
          "parameter#{found_keys.one? ? '' : 's'}: " \
          "#{found_keys.map { |k| "`#{k}`" }.join(', ')} requires: " \
          "#{(keys - found_keys).map { |k| "`#{k}`" }.join(', ')}."
        end
      end
    end

    def check!
      @model = instance_exec(&self.class.model_proc)
      @scope = instance_exec(&self.class.scope_proc)

      each_listener_for :check do |seek_params, opts, op|
        next instance_exec(&op) if seek_params.empty?
        next if !opts[:any] && !seek_params.all? { |p| params.key?(p) }

        vals = seek_params.map { |p| params[p] }
        instance_exec(*vals, &op)
      end
    end

    def apply!
      each_listener_for :apply do |seek_params, opts, op|
        next update_scope! instance_exec(&op) if seek_params.empty?
        next if !opts[:any] && !seek_params.all? { |p| params.key?(p) }

        vals = seek_params.map { |p| params[p] }
        update_scope! instance_exec(*vals, &op)
      end
    end

    def solo?
      @has_solo_param ? true : false
    end

    def bad!(message)
      raise BadParamError, message
    end

    def listeners_for(type)
      @listeners[type] ||= begin
        sorted_keys = @params.keys

        builder.listeners_for(type).sort_by do |_, keys|
          next -1 if !keys || keys.empty?
          i = sorted_keys.index(keys.first)
          i ? i : -1
        end
      end
    end

    def each_listener_for(type, &block)
      listeners_for(type).each do |t, params, opts, op|
        block.(params, opts, op)
      end
    end

    def to_scope
      extract!
      verify!
      check!
      apply!
      @scope
    end
  end
end
