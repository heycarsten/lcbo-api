module QueryHelper
  class Finder

    attr_reader :request, :params

    def initialize(request, params)
      @request = request
      @params = params
    end

    def self.find(*args)
      if (instance = get(*args))
        instance.as_json
      else
        raise NotFoundError, "No #{type} exists with id: #{args.join(', ')}."
      end
    end

    def self.type
      to_s.sub('Finder', '').downcase
    end

    def as_json
      { :result => self.class.find(*as_args) }
    end

    def as_csv
      self.class.find(*as_args).map { |row| row.join(',') }.join("\n")
    end

  end
end
