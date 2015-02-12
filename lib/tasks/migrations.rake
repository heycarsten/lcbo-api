namespace :migrations do
  desc 'Normalize producer information'
  task associate_producers: :environment do
    DataMigrator.associate_producers!

    puts 'Marking dead producers...'

    Producer.mark_dead! do
      STDOUT.print('.')
      STDOUT.flush
    end

    puts
    puts '> Done'
  end

  desc 'Identify Ontario Craft Brewers'
  task identify_ocb_producers: :environment do
    DataMigrator.identify_ocb_producers!
  end

  desc 'Normalize producer information and identify Ontario Craft Brewers'
  task normalize_producers: [:associate_producers, :identify_ocb_producers]

  desc 'Clean product categories'
  task clean_product_categories: :environment do
    DataMigrator.clean_product_categories!
  end

  desc 'Normalize category information'
  task normalize_categories: [:environment, :clean_product_categories] do
    DataMigrator.normalize_categories!

    puts 'Marking dead categories...'

    Category.mark_dead! do
      STDOUT.print('.')
      STDOUT.flush
    end

    puts
    puts '> Done'
  end

  desc 'Normalize all data in the system'
  task normalize: [:normalize_producers, :normalize_categories]
end
