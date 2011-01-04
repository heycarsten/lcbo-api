require 'amatch'
require 'stringex'

module Fuzz

  def self.redis=(rdb)
    @redis = rdb
  end

  def self.redis
    @redis ||= Redis.connect
  end

  def self.dictionaries
    @dictionaries ||= {}
  end

  def self.keyspace=(value)
    @keyspace = value
  end

  def self.keyspace
    @keyspace
  end

  def self.add_dictionary(name, opts = {})
    dictionaries[name.to_s] = Dictionary.new(name.to_s, opts)
  end

  def self.recache
    dictionaries.values.each { |dict| dict.recache }
  end

  def self.[](name, query = nil)
    dict = dictionaries[name.to_s]
    raise ArgumentError, "#{name} is not a known dictionary" unless dict
    query ? dict.suggest(query) : dict
  end


  class Dictionary

    def initialize(name, opts = {})
      @name          = name.to_s
      @source_proc   = (opts[:source]        || -> { [] })
      @min_word_size = (opts[:min_word_size] || 4)
      @stop_words    = (opts[:stop_words]    || [])
      if self.has_cache?
        @words = self.cached_words
      else
        self.recache
      end
    end

    def has_cache?
      cached_words.size > 0
    end

    def recache
      @words = nil
      Fuzz.redis.del(key)
      source_words.each { |word| Fuzz.redis.sadd(key, word) }
      @words = cached_words
    end

    def source_words
      @source_proc.().
        reject { |word| '' == word.to_s.strip }.
        map { |word|
          word.
            to_ascii.
            downcase.
            gsub(/[0-9]+|[\*\'\.]|\-/, '').
            gsub(/\s+/, ' ').
            strip.
            split
        }.
        flatten.
        reject { |word|
          word.length < @min_word_size || @stop_words.include?(word)
        }.
        uniq
    end

    def suggest(term)
      Hash[
        @words.map { |word| [
          Amatch::Levenshtein.new(word).match(term.to_ascii.downcase),
          word
        ]}
      ].min[1]
    end

    protected

    def cached_words
      Fuzz.redis.smembers(key)
    end

    def key
      if (ks = Fuzz.keyspace)
        "fuzzdictionary:#{ks}:#{@name}"
      else
        "fuzzdictionary:#{@name}"
      end
    end

  end

end