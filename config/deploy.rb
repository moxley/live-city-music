require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

set :domain, 'bandlist.moxicon.net'
set :deploy_to, '/var/www/bandlist'
set :repository, 'git@bitbucket.org:moxley/bandlist.git'
set :branch, ENV['branch'] || "master"
set :shared_paths, ['bin', 'log', 'public/assets', 'tmp', 'vendor/bundle']
set :user, 'deploy'    # Username in the server to SSH to.

task :setup => :environment do
  ['bin', 'bundle', 'log', 'public', 'tmp', 'vendor'].each do |name|
    queue! %[mkdir -p "#{deploy_to}/shared/#{name}"]
    queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/#{name}"]
  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      queue "sudo /etc/init.d/sidekiq stop || true"
      queue "sudo /etc/init.d/sidekiq start"
      queue "sudo /etc/init.d/unicorn restart"
    end
  end
end
