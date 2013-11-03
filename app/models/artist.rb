class Artist < ActiveRecord::Base
  attr_accessor :genre_points

  acts_as_taggable_on :genres

  delegate :genre_points, to: :genre_calculator

  has_many :events

  def venues
    ids = Venue.joins(events: :artists_events).
                where(artists_events: {artist_id: id}).
                group('venues.id').
                pluck(:id)
    Venue.where(id: ids)
  end

  def genre_calculator
    @genre_calculator ||= GenreCalculator.new(self).calculate
  end

  def genre_points_by_name
    genre_calculator.points_by_genre
  end

  def played_with
    Artist.
      joins('JOIN artists_events ae ON ae.artist_id = artists.id AND ae.artist_id != %d' % id).
      joins('JOIN artists_events ae2 ON ae2.artist_id = %d
             AND ae2.event_id = ae.event_id' % id)
  end

  def genre_taggings
    Tagging.includes(:tag).where(taggable_type: 'Artist', taggable_id: id)
  end

  def genre_taggings_by_name(genre_name)
    genre_taggings.select { |t| t.tag.name == genre_name }
  end
end
