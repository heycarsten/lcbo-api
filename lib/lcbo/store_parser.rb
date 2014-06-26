module LCBO
  class StoreParser < Parser
    FEATURE_FIELDS = {
      :has_wheelchair_accessability => 'wheelchair',
      :has_bilingual_services       => 'bilingual',
      :has_product_consultant       => 'consultant',
      :has_tasting_bar              => 'tasting',
      :has_beer_cold_room           => 'cold',
      :has_special_occasion_permits => 'permits',
      :has_vintages_corner          => 'corner',
      :has_parking                  => 'parking',
      :has_transit_access           => 'transit' }

    emits :id do
      query_params[:id].to_i
    end

    emits :name do
      CrawlKit::TitleCaseHelper[doc.css('.infoWindowTitle')[0].content.strip]
    end

    emits :tags do
      CrawlKit::TagHelper[
        name,
        address_line_1,
        address_line_2,
        city,
        postal_code
      ]
    end

    emits :address_line_1 do
      data = info_nodes[2].content.strip
      unless data
        raise CrawlKit::MalformedError,
        "unable to locate address for store #{idid}"
      end
      CrawlKit::TitleCaseHelper[data.gsub(/[\n\r\t]+/, ' ').strip]
    end

    emits :address_line_2 do
      data = info_nodes[3].content.strip
      CrawlKit::TitleCaseHelper[data] if data != ''
    end

    emits :city do
      pos = get_info_node_offset(4)
      data = info_nodes[pos].content.strip.split(',')[0]
      CrawlKit::TitleCaseHelper[data.strip] if data
    end

    emits :postal_code do
      pos = get_info_node_offset(4)
      data = info_nodes[pos].content.strip.split(',')[1]
      unless data
        raise CrawlKit::MalformedError,
        "unable to locate postal code for store #{id}"
      end
      data.strip.upcase
    end

    emits :telephone do
      pos = get_info_node_offset(6)
      CrawlKit::PhoneHelper[
        info_nodes[pos].content.sub('Telephone:', '').strip
      ]
    end

    emits :fax do
      if has_fax?
        pos = (info_nodes_count - 1)
        CrawlKit::PhoneHelper[
          info_nodes[pos].content.sub('Fax:', '').strip
        ]
      end
    end

    emits :latitude do
      node = doc.css('#latitude').first
      node ? node[:value].to_f : nil
    end

    emits :longitude do
      node = doc.css('#longitude').first
      node ? node[:value].to_f : nil
    end

    Date::DAYNAMES.map { |d| d.downcase }.each do |day|
      emits :"#{day}_open" do
        open_close_times[day.downcase][0]
      end

      emits :"#{day}_close" do
        open_close_times[day.downcase][1]
      end
    end

    FEATURE_FIELDS.keys.each do |field|
      emits(field) { features[field] }
    end
  end
end
