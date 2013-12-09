# http://en.wikipedia.org/wiki/Cron
# Learn more: http://github.com/javan/whenever

set :output, "/var/www/bandlist/shared/log/cron_log.log"

# 4:00pm PDT
every :day, at: '00:00' do
  rake 'collect_pages'
end

# 4:30pm PDT
every :day, at: '00:30' do
  rake 'calculate_genres'
end
