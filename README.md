# What

LiveCityMusic is an application for discovering live music. Quite simply, it
presents today's shows categorized my musical genre. This allows you to find an
artist for tonight who plays one of your favorite kinds of music, without
knowing the artist beforehand. Additionally, it has the ability to display the
artist's play history and to display who else was on the bill for each show.
This gives you more context in deciding which artist to see.

## How to use

Currently, the application presents a simple web UI to demonstrate a minimally
viable product. Afterwards, it will expose an API that can be consumed by native
mobile devices and dynamic web clients.

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
