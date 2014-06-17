module LegacyModelApi
  extend ActiveSupport::Concern

  module ClassMethods
    def has_api(opts = {})
      self.not_csv_columns  = (opts.delete(:not_csv) || []).map(&:to_s)
      self.private_columns  = (opts.delete(:private) || []).map(&:to_s)
      self.column_aliases   = (opts.delete(:aliases) || {}).stringify_keys
      self.remapped_columns = (opts.delete(:remap)   || {}).stringify_keys

      raise ArgumentError, "options contains unknown keys" if opts.any?
    end

    def private_columns
      @private_columns
    end

    def private_columns=(val)
      @private_columns = val
    end

    def column_aliases
      @column_aliases
    end

    def column_aliases=(val)
      @column_aliases = val
    end

    def not_csv_columns
      @not_csv_columns
    end

    def not_csv_columns=(val)
      @not_csv_columns = val
    end

    def remapped_columns
      @remapped_columns
    end

    def remapped_columns=(val)
      @remapped_columns = val
    end

    def public_columns
      @public_columns ||= (column_names - private_columns)
    end

    def csv_columns
      @csv_columns ||= (public_columns - not_csv_columns)
    end

    def human_csv_columns
      @human_csv_columns ||= begin
        csv_columns.map { |c| c.to_s.gsub('_', ' ').titlecase }
      end
    end

    def api_values(hsh)
      column_aliases.each_pair   { |to, from| hsh[to] = hsh[from] }
      remapped_columns.each_pair { |from, to| hsh[to] = hsh.delete(from) }
      hsh.except(*private_columns)
    end

    def as_json(obj)
      api_values(obj.as_json)
    end

    def as_csv(obj, with_header = false)
      rows = []
      rows << human_csv_columns if with_header
      rows << as_csv_row(obj)
      rows
    end

    def as_csv_row(obj)
      hsh = api_values(obj)
      csv_columns.map { |c| hsh[c] }
    end
  end

  def as_json(*args)
    self.class.api_values(super)
  end

  def as_csv(with_header = false)
    self.class.as_csv(as_json, with_header)
  end
end
