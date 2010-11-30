namespace :cron do
  desc 'Begin crawl'
  task :crawl => :environment do
    Crawler.run
  end
end
