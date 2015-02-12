namespace :migrations do
  desc 'Normalize producer information'
  task normalize_producers: :environment do
    puts 'Creating producers and associating products...'
    Product.where(producer_id: nil).find_each do |product|
      product.associate_producer!
      STDOUT.print '.'
      STDOUT.flush
    end
    puts
    puts '> Done'
  end

  desc 'Identify Ontario Craft Brewers'
  task identify_ocb: :environment do
    puts 'Finding OCB producers...'

    producers = LCBO::OCBProducersCrawler.parse[:producers]
    ocb_names = Hash[producers.map { |p| [p[:normalized_name], p[:name]] }]

    Producer.where(is_ocb: false).find_each do |producer|
      found_name = nil
      lcbo_norm  = LCBO::OCBProducersCrawler.normalize_name(producer.name)

      ocb_names.each_pair do |ocb_norm, ocb_name|
        next unless lcbo_norm.starts_with?(ocb_norm)
        found_name = ocb_name
        break
      end

      next unless found_name

      producer.update(
        is_ocb: true,
        name: found_name
      )

      STDOUT.print('.')
      STDOUT.flush
    end

    puts
    puts '> Done'
  end
end
