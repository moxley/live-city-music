# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

if File.exists?("#{ENV['HOME']}/.env")
  File.open("#{ENV['HOME']}/.env").each_line do |line|
    line.strip!
    line.sub!(/export /, '')
    name, value = line.split('=')
    ENV[name] = value
  end
end

require File.expand_path('../config/application', __FILE__)

Bands::Application.load_tasks
