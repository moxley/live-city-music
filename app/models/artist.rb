class Artist < ActiveRecord::Base
  include TaggingHelper

  attr_accessor :dependencies

  acts_as_taggable_on :genres

  has_many :events
  has_many :genre_points, as: :target

  delegate :calculate_genre,
           :calculate_user_tagged_points,
           :calculate_name_embedded_points,
           to: :genre_calculator

  delegate :calculate_and_apply_genres, to: :genre_points_helper

  def venues
    ids = Venue.joins(events: :artists_events).
                where(artists_events: {artist_id: id}).
                group('venues.id').
                pluck(:id)
    Venue.where(id: ids)
  end

  def genre_calculator
    @genre_calculator ||= GenreCalculator.new(self)
  end

  def genre_points_helper
    @genre_points_helper ||= GenrePointsHelper.new(self)
  end

  def genre_util
    @genre_util ||= GenreUtil.new
  end

  def played_with
    Artist.
      joins('JOIN artists_events ae ON ae.artist_id = artists.id AND ae.artist_id != %d' % id).
      joins('JOIN artists_events ae2 ON ae2.artist_id = %d
             AND ae2.event_id = ae.event_id' % id)
  end

  def add_genres!(source, names)
    names.each do |name|
      genre = dependencies.find_or_create_genre(name)
      gp = dependencies.find_or_build_genre_point(target: self, genre: genre, point_type: 'self')
      gp.update_attributes!(value: 2.0)
    end
  end

  def dependencies
    @dependencies ||= Dependencies.new
  end

  private

  class Dependencies
    def find_or_build_genre_point(attrs)
      #constraints = {target_id: attrs}
      attrs[:target].genre_points << GenrePoint.create!(attrs)
    end

    def find_or_create_genre(name)
      genre_util.fuzzy_find(name) || Genre.create!(name: g)
    end

    private

    def genre_util
      @genre_util ||= GenreUtil.new
    end
  end
end
