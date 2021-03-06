# http://en.wikipedia.org/wiki/Cron
# Learn more: http://github.com/javan/whenever

set :output, "/var/www/bandlist/shared/log/cron_log.log"

# 00:05 & 12:05 Pacific
every '05 08,20 * * *' do
  rake 'pages:download'
end

# 00:30 & 12:30 Pacific
every '30 08,20 * * *' do
  rake 'updates:artists_sources'
end

# 00:45 & 12:45 Pacific
every '45 08,20 * * *' do
  rake 'calculate:genres'
end
