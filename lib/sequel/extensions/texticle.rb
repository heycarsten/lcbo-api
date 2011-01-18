# Inspired by / ripped from tenderlove's Texticle
module Sequel
  class Dataset

    def search(colnames, query, opts = {})
      return self unless query.to_s != ''

      lang = (opts[:lang] || 'simple')

      cols = Array(colnames).
        map { |c|
          SQL::Function.new(:COALESCE, c, '')
        }.
        sql_string_join(' ')

      filter("to_tsvector(#{literal lang}, #{literal cols}) @@ plainto_tsquery(#{literal lang}, ?)", query)
    end

  end
end
