# What

LiveCityMusic is an application for discovering live music. Currently, it
has a simple web UI to demonstrate a minimally viable product. Afterwards, it
will have an API that can be consumed by native mobile devices and dynamic web
clients.

## Technology

LiveCityMusic uses the following open source technologies:

* Ruby on Rails
* PostgreSQL
* Redis
* Sidekiq

## Redis setup

To have launchd start redis at login:
    ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
Then to load redis now:
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
Or, if you don't want/need launchctl, you can just run:
    redis-server /usr/local/etc/redis.conf
