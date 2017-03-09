JSONAPI.configure do |config|
  config.default_paginator = :paged
  config.default_page_size = 50
  config.maximum_page_size = 200
end

module JSONAPI
  class LinkBuilder
    private

    def module_scopes_from_class(klass)
      scopes = klass.name.to_s.split("::")[0...-1]
      scopes.shift
      scopes
    end
  end
end