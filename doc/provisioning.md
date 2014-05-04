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
  * cat > /etc/apt/sources.list.d/pgdg.list

    ```
    deb http://apt.postgresql.org/pub/repos/apt/ saucy-pgdg main
    ```
  * wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
  * apt-get update
  * apt-get upgrade
  * apt-get install postgresql-9.3 postgresql-server-dev-9.3 postgresql-client-9.3
  * If postgresql is already installed:
    * apt-get install postgresql-client-9.1 postgresql-client-common
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
  * cat >> /home/deploy/.ssh/authorized_keys

    ```
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6UIvYjuWPGOIK+tVXz2OoGnzKWYIW2kH257YxPsOV2FVm0gJ/C4AoPa++8/qAUFpvqjuyfeNpr5YHcZXGSssWeDgB0ZT7TWpZexFhQvo2la2/g//SAXfOGv2r5L8UP3GsBYWtbW5P0B6lD6ARDd7iITLzwkgAkM3+BxT0pPGwMZ1XotIPTWp43n741DHyoQhT0pQdfVGiM5DzAxCIO74LkMEE1hNMnz0sZaCSCdg3vc2D09CsnaO3Wiwmle7XS8dkcolxGV24fd8RTaxdP0Yx8b4PHbRjydJWyKr1Xo0GQvr6VoNaDTAueWD1tuB42TrOobDArpPjy+DFf2d5wRq5 moxley@clymb-macbook-pro.local
    ```
  * exit
  * create file: /etc/sudoers.d/deploy:

    ```
    deploy ALL=NOPASSWD:/etc/init.d/postgres, /etc/init.d/redis_6379, /etc/init.d/nginx, /etc/init.d/unicorn, /etc/init.d/sidekiq
    ```
  * vi ~deploy/.profile
  * Add the following:

    ```
    PATH=$PATH:/usr/local/bin
    ```

* Deployment local setup
  * Add doc/ssh_config to your ~/.ssh/config
* Set up deployment directory
  * (as "root")
  * mkdir -p /var/www/bandlist/shared/{tmp,log,public/assets}
  * chown -R deploy:deploy /var/www
* Install PostgreSQL: https://www.digitalocean.com/community/articles/how-to-install-and-use-postgresql-on-ubuntu-12-04
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
  * cp src/redis-{server,cli} ../bin/
  * mkdir /etc/redis /var/redis
  * cp utils/redis_init_script /etc/init.d/redis_6379
  * cp redis.conf /etc/redis/6379.conf
  * vi /etc/redis/6379.conf
    * Set daemonize to yes (by default it is set to no).
    * Set the pidfile to /var/run/redis_6379.pid (modify the port if needed).
    * Change the port accordingly. In our example it is not needed as the default port is already 6379.
    * Set your preferred loglevel.
    * Set the logfile to /var/log/redis_6379.log
    * Set the dir to /var/redis/6379 (very important step!)
    * /etc/init.d/redis_6379 start
* Install Git: https://www.digitalocean.com/community/articles/how-to-install-git-on-ubuntu-12-04
  * apt-get install git-core
* Install Node.js: http://stackoverflow.com/questions/16302436/install-nodejs-on-ubuntu-12-10
  * add-apt-repository ppa:chris-lea/node.js
  * apt-get update
  * apt-get install python-software-properties python g++
* Configure secrets
  * su - deploy
  * Put secrets and other environment variables in ~deploy/.env:

    ```
    export RAILS_ENV=production
    export AWS_ACCESS_KEY=***
    export AWS_SECRET_KEY=***
    export SENDGRID_PASSWORD=***
    export SENDGRID_USERNAME=***
    export DB_PASSWORD=***
    ```
  * chmod 600 ~/.env
  * echo "source ~/.env" >> ~/.profile
* Unicorn
  * Install doc/unicorn_init.sh to /etc/init.d/unicorn
  * update-rc.d unicorn defaults
  * update-rc.d unicorn enable
  * mkdir /etc/unicorn
  * cat > /etc/unicorn/bandlist.conf

    ```
    RAILS_ENV=production
    RAILS_ROOT=/var/www/bandlist/current
    ```

* Install nginx: https://www.digitalocean.com/community/articles/how-to-install-nginx-on-ubuntu-12-04-lts-precise-pangolin
  * apt-get install nginx
  * cd /etc/nginx
  * rm sites-enabled/default
  * cat > sites-available/bandlist.conf

   ```
   include /var/www/bandlist/current/config/nginx.conf;
   ```
  * ln -s /etc/nginx/sites-available/bandlist.conf sites-enabled/bandlist.conf
  * /etc/init.d/nginx start
* Sidekiq deployment
  * Install doc/sidekiq_init.sh to /etc/init.d/sidekiq
  * sudo update-rc.d sidekiq defaults
  * sudo update-rc.d sidekiq enable
* Access to bitbucket:
  * Connect to server via SSH as user "deploy", with SSH forwarding turned on (should already be configured)
  * ssh git@bitbucket.org
  * At prompt: enter "yes" to allow bitbucket.org to be added to known_hosts
  * git clone "git@bitbucket.org:moxley/bandlist.git" "/var/www/bandlist/scm" --bare
* Locally, in development environment:
  * bin/mina setup
  * ssh-agent && ssh-add
  * bin/mina deploy
