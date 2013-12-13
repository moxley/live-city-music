class Artist < ActiveRecord::Base
  include TaggingHelper

  attr_accessor :dependencies

  acts_as_taggable_on :genres

  has_many :events
  has_many :genre_points, as: :target
  has_many :job_runs, foreign_key: :target_id

  delegate :calculate_genre,
           :calculate_name_embedded_points,
           to: :genre_calculator

  delegate :calculate_and_apply_genres,
           :self_tagged_genre_points,
           :user_tagged_genre_points,
           :add_genres!,
           :add_user_tagged_genres!,
           :dependencies, # TODO remove
           to: :genre_points_helper

  def venues
    ids = Venue.joins(events: :artists_events).
                where(artists_events: {artist_id: id}).
                group('venues.id').
                pluck(:id)
    Venue.where(id: ids)
  end

  def genre_calculator
    @genre_calculator ||= DerivedGenreCalculator.new(self)
  end

  def genre_points_helper
    @genre_points_helper ||= GenrePointsHelper.new(self)
  end

  def played_with
    Artist.
      joins('JOIN artists_events ae ON ae.artist_id = artists.id AND ae.artist_id != %d' % id).
      joins('JOIN artists_events ae2 ON ae2.artist_id = %d
             AND ae2.event_id = ae.event_id' % id)
  end
end
