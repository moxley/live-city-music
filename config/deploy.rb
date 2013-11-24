require "capistrano/setup"

#set :whenever_command, "bundle exec whenever"
set :whenever_environment, -> { stage }
require "whenever/capistrano"

set :stages, ["production"]
set :application, 'bandlist'
set :repo_url, 'git@heroku.com:bandlist.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'
set :scm, :git
set :branch, ENV['branch'] || "master"
#set :repository, "git@heroku.com:bandlist.git"
set :user, "deploy"
set :use_sudo, false

# This is slow
set :deploy_via, :copy

set :ssh_options, { :forward_agent => true }
set :keep_releases, 2
role :all, %w{deploy@aws1}

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end
