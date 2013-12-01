require "capistrano/setup"

set :stages, ["production"]
set :application, 'bandlist'
set :repo_url, 'git@heroku.com:bandlist.git'

set :deploy_to, "/var/www/bandlist"
set :scm, :git
set :branch, ENV['branch'] || "master"
set :user, "deploy"
set :use_sudo, false

# This is slow
set :deploy_via, :copy

set :ssh_options, { :forward_agent => true }
set :keep_releases, 2
role :all, %w{deploy@aws1}

set :linked_dirs,  %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :bundle_flags, '--deployment --quiet'
set :unicorn_conf, "#{current_path}/config/unicorn.rb"
set :unicorn_pid,  "#{deploy_to}/shared/tmp/pids/unicorn.pid"
set :sidekiq_pid,  "../shared/tmp/pids/sidekiq.pid"
set :sidekiq_cmd, -> { "cd #{current_path} && bundle exec sidekiq -d -i 0 -P #{fetch(:sidekiq_pid)} -e production -C #{current_path}/config/sidekiq.yml -L #{current_path}/log/sidekiq.log" }

def invoke_task(task)
  Rake::Task[task.to_s].invoke
end

namespace :deploy do

  desc 'Restart everything: unicorn, nginx and sidekiq'
  task :restart do
    on roles(:app), :except => { :no_release => true } do
      invoke_task "sidekiq:restart"
      invoke_task "deploy:restart_app"
      invoke_task "deploy:reload_nginx"
    end
  end

  desc 'Start unicorn and sidekiq'
  task :start do
    #sudo "/sbin/start unicorn"
    invoke_task "unicorn:start"
    invoke_task "sidekiq:start"
  end

  desc 'Stop unicorn and sidekiq'
  task :stop do
    on roles(:all) do |host|
      invoke_task "unicorn:stop"
      invoke_task "sidekiq:stop"
    end
  end

  desc 'Restart just unicorn'
  task :restart_app do
    on roles(:app), :except => { :no_release => true } do
      invoke_task "unicorn:restart"
    end
  end

  desc 'Reload just nginx config'
  task :reload_nginx do
    on roles(:app), :except => { :no_release => true } do
      invoke_task "nginx:reload"
    end
  end

  task :update_code do
    on (:all), :except => { :no_release => true }, :max_hosts => 4 do
      on_rollback { run "rm -rf #{release_path}; true" }
      strategy.deploy!
      finalize_update
    end
  end

  namespace :web do
    desc "Put website in maintenance mode"
    task :disable do
      on roles(:web), :except => { :no_release => true } do
        template = File.read('public/503.html')
        put template, "#{shared_path}/system/maintenance.html", :mode => 0644
      end
    end

    desc "Take website out of maintenance mode"
    task :enable do
      on roles(:web), :except => { :no_release => true } do
        run "rm #{shared_path}/system/maintenance.html"
      end
    end
  end
end

namespace :sidekiq do
  desc "Start sidekiq workers"
  task :start do
    on roles(:app) do
      sudo "/etc/init.d/sidekiq start"
    end
  end
  desc "Stop sidekiq workers"
  task :stop do
    on roles(:app), :on_error => :continue do
      sudo "/etc/init.d/sidekiq stop"
    end
  end
  desc "Restart sidekiq workers"
  task :restart do
    on roles(:app) do
      invoke_task "sidekiq:stop"
      invoke_task "sidekiq:start"
    end
  end
end

namespace :unicorn do
  %i(start stop restart reload).each do |t|
    desc "#{t} unicorn instances"
    task t do
      opts = {}
      opts[:on_error] = :continue if t == 'stop'
      on roles(:app), opts do
        sudo "/etc/init.d/unicorn #{t}"
      end
    end
  end
end

namespace :nginx do
  desc "Start nginx instances"
  %i(start stop restart reload).each do |t|
    task t do
      opts = {}
      opts[:on_error] = :continue if t == 'stop'
      on roles(:app), opts do
        sudo "/etc/init.d/nginx #{t}"
      end
    end
  end
end
