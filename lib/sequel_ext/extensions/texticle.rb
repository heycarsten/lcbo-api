# Inspired by / ripped from tenderlove's Texticle
module Sequel
  class Dataset

    DISALLOWED_TSQUERY_CHARACTERS = /['?\\:]/

    def search(colnames, rawquery, opts = {})
      query = rawquery.to_s.
        gsub(/[^\w'\-]+/, ' ').
        gsub(DISALLOWED_TSQUERY_CHARACTERS, ' ').
        gsub(/\s+/, ' ').
        split.
        join('+') + ':*'
      return self if '' == query.to_s
      lang = (opts[:lang] || 'simple')
      cols = Sequel.join(Array(colnames).map { |c| SQL::Function.new(:COALESCE, c, '') }, ' ')
      where(%{
        to_tsvector(#{literal lang}, #{literal cols})
        @@
        to_tsquery(#{literal lang}, ?)
      }, query)
    end

  end
end
