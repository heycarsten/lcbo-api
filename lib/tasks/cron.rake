desc 'Run scheduled tasks'
task :cron => :environment do
  Crawler.run
end
