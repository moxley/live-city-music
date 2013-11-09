class Artist < ActiveRecord::Base
  include TaggingHelper
  include GenrePointsHelper
  include GenreCalculatorCommon

  acts_as_taggable_on :genres

  has_many :events
  has_many :genre_points, as: :target

  def venues
    ids = Venue.joins(events: :artists_events).
                where(artists_events: {artist_id: id}).
                group('venues.id').
                pluck(:id)
    Venue.where(id: ids)
  end

  delegate :calculate_genre,
           :calculate_user_tagged_points,
           :calculate_name_embedded_points,
           to: :genre_calculator

  # def calculate_and_save_genre_points
  #   calculate_genre_points.each do |attrs|
  #     genre = Genre.find_by_name(attrs[:genre_name])
  #     gp = genre_points.build value: attrs[:value], point_type: attrs[:point_type], genre_id: genre.id, source: attrs[:source]
  #     gp.save!
  #   end
  # end

  def genre_calculator
    @genre_calculator ||= GenreCalculator.new(self)
  end

  def played_with
    Artist.
      joins('JOIN artists_events ae ON ae.artist_id = artists.id AND ae.artist_id != %d' % id).
      joins('JOIN artists_events ae2 ON ae2.artist_id = %d
             AND ae2.event_id = ae.event_id' % id)
  end
end
