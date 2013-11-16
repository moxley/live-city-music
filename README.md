# README

Band information repository.

# Onboarding

* Install Heroku Toolbelt: https://toolbelt.heroku.com/
* Install heroku-config: `heroku plugins:install git://github.com/ddollar/heroku-config.git`
* Create file `.env`
* Add Amazon AWS credentials to `.env`

# Development Process

* To run rails server or rails console, use foreman: `foreman rails server`, `foreman rails console`.

# Application Patterns

* Everything in lib/ should be application agnostic, except for lib/tasks/*.rake

## TODO

* Tag relations
* Populate remaining columns: events: starts_at, venues: state
* Web-based interface

## Redis

To have launchd start redis at login:
    ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
Then to load redis now:
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
Or, if you don't want/need launchctl, you can just run:
    redis-server /usr/local/etc/redis.conf
