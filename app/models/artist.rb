class Artist < ActiveRecord::Base
  has_many :artists_events
  has_many :events, through: :artists_events
  has_many :genre_points, as: :target
  has_many :genres, through: :genre_points
  has_many :job_runs, foreign_key: :target_id

  delegate :calculate_and_apply_genres,
           :self_tagged_genre_points,
           :user_tagged_genre_points,
           :add_genres!,
           :add_user_tagged_genres!,
           to: :genre_util

  def self.today_by_genre_id(city_slug, id)
    rows = Genre.
      ungrouped_by_today(city_slug).
      where(genres: {id: id}).
      group('artists.id').
      select('artists.id artist_id, min(events.id) event_id').
      to_a

    event_ids_by_artist_ids = rows.inject({}) { |h, r| h[r.artist_id] = r.event_id; h }

    artists = Artist.
      where(id: rows.map(&:artist_id)).
      order(:name)

    events = Event.where(id: rows.map(&:event_id)).includes(:venue)
    events_by_id = events.inject({}) { |h, e| h[e.id] = e; h }

    artists.map do |artist|
      event_id = event_ids_by_artist_ids[artist.id]
      event = events_by_id[event_id]
      ArtistInEvent.new(artist, event)
    end
  end

  class ArtistInEvent
    attr_accessor :artist, :event
    delegate :name, to: :artist

    def initialize(artist, event)
      @artist = artist
      @event = event
    end

    def venue
      event.venue.name
    end
  end

  def venues
    ids = Venue.joins(events: :artists_events).
                where(artists_events: {artist_id: id}).
                group('venues.id').
                pluck(:id)
    Venue.where(id: ids)
  end

  def genre_util
    @genre_util ||= GenreUtil.new(self)
  end

  def played_with
    Artist.
      joins('JOIN artists_events ae ON ae.artist_id = artists.id AND ae.artist_id != %d' % id).
      joins('JOIN artists_events ae2 ON ae2.artist_id = %d
             AND ae2.event_id = ae.event_id' % id)
  end
end
