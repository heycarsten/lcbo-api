module LCBO
  class CatalogProductCrawler
    include Parseable

    URL_ID_RNG          = /\/([0-9]+)\Z/
    VAO_DESCRIPTION_RNG = /\AFREE (.+) until/
    DATE_RNG            = /([A-Z]{1}[a-z]+ [0-9]+, [0-9]{4}+){1}/
    VAO_DATE_RNG        = /until #{DATE_RNG} or/

    def self.parse(url)
      new(url).as_json
    end

    def initialize(url_or_id)
      if url_or_id.is_a?(String)
        @url = url_or_id
        @id  = url_or_id.match(URL_ID_RNG)[1].to_i
      else
        @id  = url_or_id
        @url = "http://www.lcbo.com/lcbo/product/sku/#{@id}"
      end

      html = LCBO.get(@url)
      @doc = Nokogiri::HTML(html)
    end

    field :id do
      @id || raise(LCBO::DafuqError, "expected product to have ID")
    end

    field :name do
      if (name = css('.pip-info .details h1')[0])
        util.titlecase(name.content.strip)
      else
        raise LCBO::DafuqError, "expected product #{id} to have a name"
      end
    end

    field :tags do
      util.tagify(
        name,
        primary_category,
        secondary_category,
        origin,
        producer_name,
        package_unit_type
      )
    end

    field :price_in_cents do
      if (dollars = util.parse_dollars(css('.prices strong')[0].content))
        (dollars * 100).to_i
      else
        0
      end
    end

    field :regular_price_in_cents do
      if has_limited_time_offer
        dollars = util.parse_dollars(css('.prices small')[0].content)
        (dollars * 100).to_i
      else
        price_in_cents
      end
    end

    field :has_limited_time_offer do
      css('.lto-end-date').length > 0
    end

    field :limited_time_offer_savings_in_cents do
      if has_limited_time_offer
        regular_price_in_cents - price_in_cents
      else
        0
      end
    end

    field :limited_time_offer_ends_on do
      if has_limited_time_offer
        # LOLCBO doesn't give all stuff an end date
        css('.lto-end-date')[0].content =~ DATE_RNG ? util.parse_date($1) : nil
      else
        nil
      end
    end

    field :bonus_reward_miles do
      if has_bonus_reward_miles
        css('.badges .air-miles span')[0].content.to_i
      else
        0
      end
    end

    field :bonus_reward_miles_ends_on do
      if has_bonus_reward_miles
        css('.air-miles-end-date')[0].content =~ DATE_RNG ? util.parse_date($1) : nil
      else
        nil
      end
    end

    field :has_bonus_reward_miles do
      css('.badges .air-miles').length > 0
    end

    field :stock_type do
      text = css('.pip-info .details small')[0].content.strip

      if text.include?('LCBO')
        'LCBO'
      else
        'VINTAGES'
      end
    end

    field :primary_category do
      css('#WC_BreadCrumb_Link_1')[0].content.strip
    end

    field :secondary_category do
      css('#WC_BreadCrumb_Link_2')[0].content.strip
    end

    field :tertiary_category do
      if (node = css('#WC_BreadCrumb_Link_3')[0])
        node.content.strip
      else
        nil
      end
    end

    field :origin do
      return nil unless val = details[:made_in]
      val.
        gsub('/Californie', '').
        gsub('Bosnia\'Hercegovina', 'Bosnia and Herzegovina').
        gsub('Is. Of', 'Island of').
        gsub('Italy Quality', 'Italy').
        gsub('Usa-', '').
        gsub(', Rep. Of', '').
        gsub('&', 'and').
        gsub('Region Not Specified, ', '').
        split(',').
        map { |s| s.strip }.
        reject { |s| s == '' }.
        uniq.
        join(', ')
    end

    def package_data
      @package_data ||= util.parse_package(package)
    end

    field :package do
      details[:package]
    end

    field :package_unit_type do
      package_data[:unit_type]
    end

    field :package_unit_volume_in_milliliters do
      package_data[:unit_volume]
    end

    field :total_package_units do
      package_data[:total_units]
    end

    field :volume_in_milliliters do
      package_data[:package_volume]
    end

    field :alcohol_content do
      val = details[:alc_vol]

      if val && val.end_with?('%')
        (val.sub('%', '').to_f * 100).to_i
      else
        0
      end
    end

    field :price_per_liter_of_alcohol_in_cents do
      if alcohol_content > 0 && volume_in_milliliters > 0
        alc_frac = alcohol_content.to_f / 1000.0
        alc_vol  = (volume_in_milliliters.to_f / 1000.0) * alc_frac
        (price_in_cents.to_f / alc_vol).to_i
      else
        0
      end
    end

    field :price_per_liter_in_cents do
      if volume_in_milliliters > 0
        (price_in_cents.to_f / (volume_in_milliliters.to_f / 1000.0)).to_i
      else
        0
      end
    end

    field :style do
      if (node = css('.style .text a')[0])
        node.content.strip
      else
        nil
      end
    end

    field :sugar_content do
      if (node = details_node.css('a[data-action="sweetness-chart"]')[0])
        node.content.strip
      else
        nil
      end
    end

    field :sugar_in_grams_per_liter do
      val = details[:sugar_content]

      if val && val.end_with?('g/L')
        val.sub('g/L', '').to_i
      else
        nil
      end
    end

    field :producer_name do
      val = details[:by]

      if !val || val == 'N/A'
        nil
      else
        util.titlecase(val)
      end
    end

    field :varietal do
      details[:varietal]
    end

    field :released_on do
      val = details[:release_date]

      if val == 'N/A'
        nil
      else
        util.parse_date(val)
      end
    end

    field :is_discontinued do
      css('.product-discontinued').size > 0
    end

    field :has_value_added_promotion do
      vao_info ? true : false
    end

    field :is_seasonal do
      css('.seasonal-product').size > 0
    end

    field :is_vqa do
      css('i[title="VQA"]').size > 0
    end

    field :is_kosher do
      css('.kosher-product').size > 0
    end

    field :tasting_note do
      if node = css('.description blockquote')[0]
        node.content.strip
      else
        nil
      end
    end

    field :description do
      details[:description]
    end

    field :value_added_promotion_description do
      if vao_info
        vao_info[:desc]
      else
        nil
      end
    end

    field :value_added_promotion_ends_on do
      if vao_info
        vao_info[:date]
      else
        nil
      end
    end

    private

    def vao_info
      @vao_info ||= begin
        if (node = css('.value-add-end-date')[0])
          text = node.content.strip
          { desc: text.match(VAO_DESCRIPTION_RNG)[1].strip,
            date: util.parse_date(text.match(VAO_DATE_RNG)[1].strip) }
        else
          nil
        end
      end
    end

    def details_node
      @details_node ||= css('.product-details dl')[0]
    end

    def details
      @details ||= begin
        h   = {}
        set = details_node.element_children

        set.each_with_index do |node, i|
          next unless node.name == 'dt'
          h.update(
            case (label = node.content.strip)
            when /alcohol\/vol/i
              { alc_vol: set[i + 1].content.strip }
            when /made in/i
              { made_in: set[i + 1].content.strip }
            when /by/i
              { by: set[i + 1].content.strip }
            when /release date/i
              { release_date: set[i + 1].content.strip }
            when /varietal/i
              { varietal: set[i + 1].content.strip }
            when /sugar content/i
              { sugar_content: set[i + 1].content.strip }
            when /description/i
              { description: set[i + 1].content.strip }
            when / mL /
              { package: label }
            else
              {}
            end
          )
        end

        h
      end
    end

    def before_parse
      nodes = @doc.css('.error-container .message')
      return unless nodes.size > 0
      raise LCBO::NotFoundError, "product #{@id} does not exist"
    end
  end
end
