# Provisioning

* Set up instance on Amazon EC2
* Install gcc
  * https://help.ubuntu.com/community/InstallingCompilers
  * (as root)
  * apt-get update
  * apt-get upgrade
  * apt-get install build-essential
  * gcc -v
  * make -v
* Install openssl-dev:
  * apt-get -y install zlib1g-dev libreadline-dev libssl-dev libcurl4-openssl-dev
* Install postgresql-server-dev-x.y
  * psql --version
  * apt-get install postgresql-server-dev-9.1
* Install Ruby + Rails:
  * sudo su -
  * cd /usr/local
  * ruby=ruby-2.0.0-p451
  * wget http://cache.ruby-lang.org/pub/ruby/2.0/${ruby}.tar.gz
  * tar xzvf ${ruby}.tar.gz
  * cd ${ruby}
  * ./configure
  * make
  * make install
  * gem update --system --no-document
  * gem install rails --no-document
  * gem install bundler --no-document
  * gem install rake --no-document
* Add 'deploy' user:
  * sudo su
  * useradd --create-home --user-group --shell /bin/bash deploy
  * su - deploy
  * mkdir .ssh
  * chmod 700 .ssh
  * touch .ssh/authorized_keys
  * chmod 600 .ssh/authorized_keys
  * exit
  * cat /home/ubuntu/.ssh/authorized_keys >> /home/deploy/.ssh/authorized_keys
* Deployment local setup
  * Add your ssh public key to ~deploy:/.ssh/authorized_keys on the target system
  * Add doc/ssh_config to your ~/.ssh/config
* Set up deployment directory
  * (as "root")
  * mkdir -p /var/www/bandlist/current
  * mkdir -p /var/www/bandlist/shared/log
  * mkdir -p /var/www/bandlist/shared/tmp
  * chown -R deploy:deploy /var/www
* Install PostgreSQL: https://www.digitalocean.com/community/articles/how-to-install-and-use-postgresql-on-ubuntu-12-04
  * apt-get install postgresql postgresql-contrib
  * su - postgres
  * psql
  * create user bands with password '?????';
  * create database bands_production with owner=bands;
  * \q
  * exit
  * su - deploy
  * psql -U bands -h localhost --password bands_production
  * \q
* Install Redis: http://redis.io/topics/quickstart
  * cd /usr/local
  * wget http://download.redis.io/redis-stable.tar.gz
  * tar xzvf redis-stable.tar.gz
  * cd redis-stable
  * make
  * cp src/redis-server ../bin/
  * cp src/redis-cli ../bin/
  * mkdir /etc/redis
  * mkdir /var/redis
  * cp utils/redis_init_script /etc/init.d/redis_6379
  * cp redis.conf /etc/redis/6379.conf
  * vi /etc/redis/6379.conf
    * Set daemonize to yes (by default it is set to no).
    * Set the pidfile to /var/run/redis_6379.pid (modify the port if needed).
    * Change the port accordingly. In our example it is not needed as the default port is already 6379.
    * Set your preferred loglevel.
    * Set the logfile to /var/log/redis_6379.log
    * Set the dir to /var/redis/6379 (very important step!)
* Install Git: https://www.digitalocean.com/community/articles/how-to-install-git-on-ubuntu-12-04
  * apt-get install git-core
* Install Node.js: http://stackoverflow.com/questions/16302436/install-nodejs-on-ubuntu-12-10
  * add-apt-repository ppa:chris-lea/node.js
  * apt-get update
  * apt-get install python-software-properties python g++ make
* Configure secrets
  * Put secrets and other environment variables in ~/.env:

    ```
    export RAILS_ENV=production
    export AWS_ACCESS_KEY=***
    export AWS_SECRET_KEY=***
    export SENDGRID_PASSWORD=***
    export SENDGRID_USERNAME=***
    export DB_PASSWORD=***
    ```
  * Chmod it with 600
  * In ~deploy/.profile, add: source ~/.env
* Unicorn service init
  * Install doc/unicorn_init.sh to /etc/init.d/unicorn
  * update-rc.d unicorn defaults
  * update-rc.d unicorn enable
* Install nginx: https://www.digitalocean.com/community/articles/how-to-install-nginx-on-ubuntu-12-04-lts-precise-pangolin
  * apt-get install nginx
* Sidekiq deployment
  * Install doc/sidekiq_init.sh to /etc/init.d/sidekiq
  * sudo update-rc.d sidekiq defaults
  * sudo update-rc.d sidekiq enable
* Access to bitbucket:
  * As "deploy", with SSH forwarding turned on:
  * ssh git@bitbucket.org
  * At prompt: enter "yes" to allow bitbucket.org to be added to known_hosts
  * git clone "git@bitbucket.org:moxley/bandlist.git" "/var/www/bandlist/scm" --bare
* Locally, in development environment:
  * bundle install --path .bundle --binstubs
  * bin/mina setup
  * ssh-agent && ssh-add
  * bin/mina deploy
