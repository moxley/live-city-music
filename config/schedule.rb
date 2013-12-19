# http://en.wikipedia.org/wiki/Cron
# Learn more: http://github.com/javan/whenever

set :output, "/var/www/bandlist/shared/log/cron_log.log"

# 12:00 PDT
every :day, at: '20:00' do
  rake 'collect_pages'
end

# 12:30 PDT
every :day, at: '20:30' do
  rake 'updates:artists_sources'
end

# 12:45 PDT
every :day, at: '20:45' do
  rake 'calculate:genres'
end
