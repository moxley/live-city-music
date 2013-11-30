# Provisioning

* Set up instance on Amazon EC2
* # Install Ruby + Rails: https://www.digitalocean.com/community/articles/how-to-install-ruby-on-rails-on-ubuntu-12-04-lts-precise-pangolin-with-rvm
* Install Ruby + Rails:
  * sudo su -
  * cd /usr/local
  * ruby=ruby-2.0.0-p353
  * wget http://cache.ruby-lang.org/pub/ruby/2.0/${ruby}.tar.gz
  * tar xzvf ${ruby}.tar.gz
  * cd ${ruby}
  * ./configure
  * make
  * gem update --system --no-document
  * gem install rails --no-document
  * gem install bundler --no-document
  * gem install rake --no-document
* Set up deployment directory
  * cd /var/www/bandlist/current
  * bundle install --deployment
* Install PostgreSQL: https://www.digitalocean.com/community/articles/how-to-install-and-use-postgresql-on-ubuntu-12-04
  * sudo su - postgres
  * psql
  * create user bands with password '?????';
  * create database bands_production with owner=bands;
  * \q
  * exit
  * # As 'deploy':
  * psql -U bands -h localhost --password bands_production
  * \q
* Install Redis: http://redis.io/topics/quickstart
* Install Git: https://www.digitalocean.com/community/articles/how-to-install-git-on-ubuntu-12-04
* Install Node.js: http://stackoverflow.com/questions/16302436/install-nodejs-on-ubuntu-12-10
* Add 'deploy' user:
  * sudo su
  * useradd --create-home --user-group --shell /bin/bash deploy
  * su - deploy
  * mkdir .ssh
  * chmod 700 .ssh
  * touch .ssh/authorized_keys
  * chmod 600 .ssh/authorized_keys
  * exit
  * cat /home/ubuntu/.ssh/authorized_keys >> /home/deploy/.ssh/
* Configure secrets
  * Save ~/.aws with AWS credentials. Chmod it with 600
  * In ~deploy/.profile: source ~/.aws
  * Save ~/.sendgrid with Sendgrid credentials. Chmod it with 600
  * In ~deploy/.profile: source ~/.sendgrid
* Unicorn
  * Install doc/unicorn_init.sh to /etc/init.d/unicorn
  * update-rc.d unicorn defaults
  * update-rc.d unicorn enable
* Install nginx: https://www.digitalocean.com/community/articles/how-to-install-nginx-on-ubuntu-12-04-lts-precise-pangolin
* Sidekiq deployment
  * Install doc/sidekiq_init.sh to /etc/init.d/sidekiq
  * sudo update-rc.d sidekiq defaults
  * sudo update-rc.d sidekiq enable
* Deployment local setup
  * Add your ssh public key to ~deploy:/.ssh/authorized_keys on the target system
  * Add doc/ssh_config to your ~/.ssh/config
