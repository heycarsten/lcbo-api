set :output, (Rails.root + 'log' + 'cron.log').to_s

every 1.day, :at => '1:00 AM' do
  rake 'lcbo:crawl:start'
end
