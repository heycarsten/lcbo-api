set :output, '/home/lcboapi/logs/cron.log'

every 1.day, :at => '3:43 AM' do
  rake 'cron'
end
