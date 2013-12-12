class Artist < ActiveRecord::Base
  include TaggingHelper

  attr_accessor :dependencies

  acts_as_taggable_on :genres

  has_many :events
  has_many :genre_points, as: :target
  has_many :job_runs, foreign_key: :target_id

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
    @genre_calculator ||= DerivedGenreCalculator.new(self)
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
      gp = dependencies.find_or_initialize_genre_point(target: self, genre: genre, point_type: 'self_tag', source: source)
      gp.update_attributes!(value: 2.0)
    end
  end

  def dependencies
    @dependencies ||= Dependencies.new
  end

  def self_tagged_genre_points
    genre_points.where(point_type: 'self_tag').includes(:genre)
  end

  private

  class Dependencies
    def find_or_initialize_genre_point(attrs)
      %i[target genre point_type source].each do |a|
        raise ArgumentError, "Missing :#{a}" if attrs[a].blank?
      end
      constraints = {target_id:   attrs[:target].id,
                     target_type: attrs[:target].class.to_s,
                     genre_id:    attrs[:genre].id,
                     point_type:  attrs[:point_type],
                     source_type: attrs[:source].class.to_s,
                     source_id:   attrs[:source].id}
      GenrePoint.where(constraints).first_or_initialize
    end

    def find_or_create_genre(name)
      genre_util.fuzzy_find(name) || Genre.create!(name: name)
    end

    private

    def genre_util
      @genre_util ||= GenreUtil.new
    end
  end
end
