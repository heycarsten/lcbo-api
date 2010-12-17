set :output, (Rails.root + 'log' + 'cron.log').to_s

every 1.day, :at => '3:43 AM' do
  rake 'cron'
end
