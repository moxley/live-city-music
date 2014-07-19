# Live City Music

* **The Problem:** I want to go see a show tonight,
  but I don't know any of the bands listed in
  today's shows listing.
* Portland Mercury:

  ![mercury music today](http://cl.ly/image/3Q3b3X45310C/mercury-music-today.png)

* **The Solution** View artists by genre
* Discover new, live music, performing tonight

## Phase 1

* Pull event data and email it
* 1 month
* Create schema
* Batch import data into database
* 2000 artists

## HTML parsing

* Portland Mercury page: http://www.portlandmercury.com/portland/EventSearch?eventSection=807941&narrowByDate=Today
* The Mercury API
* Runs twice daily
* HTML isn't always semantic???

   ```html
   <h3>
     <a href="http://www.portlandmercury.com/portland/lents-1st-annual-oktoberfest/Event?oid=10556451">
       Lents 1st Annual Oktoberfest:

       Wilkinson Blades, Race of Strangers, Garden Goat and Beaver Boogie Band
     </a>
   </h3>

   Sun., Sept. 29, 12 p.m.
   <br />$5
   ```
* `PageParse::MercuryParser#parse_header`

## Assigning Genres

* Goal: 80% of artists
* User-assigned?

## Derived Genres

* Embedded in artist name
* `%w(jazz rock latin country)`
* GenrePoints for the band "Filter"

  ```sql
  -- GenrePoints for "Filter"
  -- "Filter" ID: 8250
  SELECT * FROM genre_points
  WHERE target_type = 'Artist'
  AND target_id=8250;
  ```

* Artists who have shared the bill with "Filter"

  ```sql
  -- Artists who have played with "Filter"
  -- "Filter" ID: 8250
  SELECT * FROM artists WHERE id IN (
    SELECT ae.artist_id
    FROM artists_events ae
    WHERE ae.event_id IN (
      SELECT DISTINCT e.id FROM events e
      JOIN artists_events ae ON ae.event_id = e.id
      WHERE ae.artist_id=8250
    )
    AND ae.artist_id != 8250
  )
  ```
* Artist plays at known Jazz club
* `GenreUtil`
  * `#genres_in_name`
* Runs twice daily

## Phase 2

![commit activity](http://cl.ly/image/3M2w0i3W3a3h/phase-1-activity.png)

* The island of Kawai, HI
* Autonomous data fetching and importing
* Band profiles

## Band Profile Services

* ReverbNation.com
* Bandcamp.com
* Discogs

## Autonomous operation

## Tech

* Ruby on Rails
* PostgreSQL
* Sidekiq with Redis (http://sidekiq.org/)
* Mina (http://nadarei.co/mina/)
* ApiPie (API documentation)

## Sidekiq

* Messages run in threads, not processes
* Up to 10x resource savings
* Author lives in town, works full time on Sidekiq
* Requires Redis
* Only runs Ruby messages
