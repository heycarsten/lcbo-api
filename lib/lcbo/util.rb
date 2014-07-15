require 'unicode_utils'
require 'date'

module LCBO
  module Util
    SMALL_WORDS = %w[
      a an and as at but by en for if in of del de on or the to v v. via
      vs.
    ]

    ACRONYMS = %w[
      i ii iii iv v vi vii viii ix x xiii xi vqa vsop xo nq5 vs xxx igt xoxo
      srl bdb cvbg ocb lcbo gtm hf yo vs ipa doc docg bv
    ]

    MONTH_NAMES_TO_NUMBERS = {
      'Jan'       => 1,
      'January'   => 1,
      'Feb'       => 2,
      'February'  => 2,
      'Mar'       => 3,
      'March'     => 3,
      'Apr'       => 4,
      'April'     => 4,
      'May'       => 5,
      'Jun'       => 6,
      'June'      => 6,
      'Jul'       => 7,
      'July'      => 7,
      'Aug'       => 8,
      'August'    => 8,
      'Sep'       => 9,
      'September' => 9,
      'Oct'       => 10,
      'October'   => 10,
      'Nov'       => 11,
      'November'  => 11,
      'Dec'       => 12,
      'December'  => 12
    }

    DELETION_RE       = /\"|\\|\/|\(|\)|\[|\]|\./
    WHITESPACE_RE     = /\*|\+|\&|\_|\,|\s/
    PACKAGE_VOLUME_RE = /([0-9]+|[0-9]+x[0-9]+) (mL) ([a-z]+)/
    PRICE_RE          = /\$([0-9,]+\.[0-9]{1,2}){1}/

    module_function

    def parse_dollars(string)
      if (match = string.match(PRICE_RE)[1])
        match.gsub(',', '').to_f
      else
        nil
      end
    end

    def upcase(string)
      UnicodeUtils.simple_upcase(string)
    end

    def downcase(string)
      UnicodeUtils.simple_downcase(string)
    end

    def capitalize(string)
      UnicodeUtils.titlecase(string)
    end

    def titlecase(string)
      preclean = lambda { |s|
        # Strip bracketed stuff and trailing junk: Product (Junk)**
        s.gsub(/\((.+?)\)|\*+|\((.+?)\Z/, '').strip
      }
      count = 0 # Ewwww
      capitalize(preclean.(string)).split.map do |word|
        count += 1
        case word.downcase
        when /[\w]\/[\w]/ # words with slashes
          word.split('/').map { |w| capitalize(w) }.join(' / ')
        when /[\w]\&[\w]/ # words with &, like E&J
          word.split('&').map { |w| capitalize(w) }.join('&')
        when /[\w]\-[\w]/ # words with dashes, like "Super-Cool"
          word.split('-').map { |w| capitalize(w) }.join('-')
        when /[\w]\.[\w]/ # words with dots, like "A.B.C."
          word.split('.').map { |w| upcase(w) }.join('.') + '.'
        when *SMALL_WORDS
          1 == count ? word : word.downcase
        when *ACRONYMS
          word.upcase
        else
          word
        end
      end.
      join(' ').
      gsub(/(['’])S\b/, '\1s'). # Word'S => Word's
      gsub(/(\S{1})'(\S{2,})/u) { "#{$1}'#{capitalize $2}" } # D'aux => D'Aux
    end

    def flatten(values)
      downcase(values.flatten.join(' ')).
        gsub(DELETION_RE, '').
        gsub(WHITESPACE_RE, ' ').
        strip
    end

    def split(str)
      [str, str.to_ascii].
        join(' ').
        split.
        map { |word| stem(word) }.
        flatten.
        uniq
    end

    def stem(word)
      split = lambda { |word|
        if word.include?('-')
          words = word.split('-')
          a = words.dup
          a << word
          a << words.join
          a
        else
          [word]
        end
      }

      tokenize = lambda { |words|
        words.reduce([]) do |tokens, word|
          tokens << word
          tokens << word.gsub("'", '') if word.include?("'")
          tokens
        end
      }

      tokenize.(split.(word))
    end

    def tagify(*values)
      return [] if values.all? { |val| '' == val.to_s.strip }
      split(flatten(values))
    end

    def parse_package(input)
      h = {
        package_volume: 0,
        unit_volume: 0,
        total_units: 0,
        unit_type: nil }

      return h unless input

      match = input.match(PACKAGE_VOLUME_RE)
      return h unless match

      captures = match.captures
      return h unless captures.size == 3

      if captures[0].include?('x')
        h[:total_units], h[:unit_volume] = *captures[0].split('x').map(&:to_i)
      else
        h[:total_units] = 1
        h[:unit_volume] = captures[0].to_i
      end

      h[:unit_type]      = captures[2]
      h[:package_volume] = h[:total_units] * h[:unit_volume]
      h
    end

    def format_phone(input)
      return if '' == input.to_s.strip
      m = input.gsub(/[^0-9]/, '')
      "(#{m[0,3]}) #{m[3,3]}-#{m[6,4]}"
    end

    def parse_date(input)
      return unless input
      month_name, day, year = *input.gsub(',', '').split
      month = MONTH_NAMES_TO_NUMBERS[month_name]
      return unless month
      Date.new(year.to_i, month, day.to_i)
    end

    def time_to_msm(val)
      h, m, s = val.split(':').map(&:to_i)

      if h == 0
        nil
      else
        (h * 60) + m
      end
    end
  end
end
