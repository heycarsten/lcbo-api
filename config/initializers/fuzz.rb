require 'fuzz'

Fuzz.redis = $redis
Fuzz.keyspace = Rails.env
Fuzz.add_dictionary(:products,
  source: -> {
    Product.
      select(:name).
      where(is_dead: false).
      all.
      map(&:name)
  },
  stop_words:    %w[ woods ],
  min_word_size: 5
)
