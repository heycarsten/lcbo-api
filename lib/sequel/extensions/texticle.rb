module Sequel
  class Dataset

    def search(colnames, query, opts = {})
      return self unless query.to_s != ''

      lang = (opts[:lang] || 'english')

      term = query.
        gsub(/[^\w\*\"]+/, ' ').
        scan(/"([^"]+)"|(\S+)/).
        flatten.
        compact.
        map { |lex|
          lex.gsub!(' ', '\\ ')
          lex =~ /(.+)\*\s*$/ ? "#{$1}:*" : lex
        }.
        join(' & ')

      cols = Array(colnames).
        map { |c|
          SQL::Function.new(:COALESCE, c, '')
        }.
        sql_string_join(' ')

      filter(%{
        to_tsvector(#{literal lang}, #{literal cols}) @@
        to_tsquery(#{literal lang}, ?)
      }, term)
    end

  end
end
