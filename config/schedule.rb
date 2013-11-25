# http://en.wikipedia.org/wiki/Cron

set :output, "/var/www/bandlist/shared/log/cron_log.log"

# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 1.minute do
  command "echo 'heartbeat' > /var/www/bandlist/shared/log/production.log"
end
