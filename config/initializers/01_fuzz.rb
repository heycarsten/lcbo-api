require 'fuzz'

Fuzz.keyspace = Rails.env
Fuzz.add_dictionary(:products,
  source: -> {
    DB[:products].
      select(:name).
      filter(is_dead: false).
      all.
      map { |p| p[:name] }
  },
  stop_words:    %w[ woods ],
  min_word_size: 5
)
