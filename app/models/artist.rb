class Artist < ActiveRecord::Base
  acts_as_taggable_on :genres
  attr_accessor :genre_points

  has_many :events

  def venues
    ids = Venue.joins(events: :artists_events).
                where(artists_events: {artist_id: id}).
                group('venues.id').
                pluck(:id)
    Venue.where(id: ids)
  end

  class GenrePoint < Struct.new(:genre, :value)
  end

  def calc_genre_points
    hash = Hash.new(0.0)

    # User tags
    genre_taggings.each do |t|
      hash[t.tag.name] += 1.0
    end

    # Peers
    played_with.each do |peer_artist|
      peer_artist.genre_taggings.each do |t|
        hash[t.tag.name] += 0.5
      end
    end

    # Artist name
    all_genres = %(jazz).downcase
    name.downcase.split.each do |n|
      if n.in?(all_genres)
        hash[n] += 0.5
      end
    end

    # Venues with genre tags
    venues.each do |v|
      v.genre_list.each do |genre_name|
        hash[genre_name] += 0.25
      end
    end

    hash.map do |genre, value|
      GenrePoint.new(genre, value)
    end
  end

  def genre_points
    @genre_points ||= calc_genre_points
  end

  def genre_points_by_name
    genre_points.inject(Hash.new(0.0)) do |hash, gp|
      hash[gp.genre] = gp.value
      hash
    end
  end

  def played_with
    Artist.
      joins('JOIN artists_events ae ON ae.artist_id = artists.id AND ae.artist_id != %d' % id).
      joins('JOIN artists_events ae2 ON ae2.artist_id = %d
             AND ae2.event_id = ae.event_id' % id)
  end

  def genre_value(genre_name)
    genre_points.detect { |gp| gp.genre == genre_name }.try(:value)
  end

  def genre_taggings
    Tagging.includes(:tag).where(taggable_type: 'Artist', taggable_id: id)
  end

  def genre_taggings_by_name(genre_name)
    genre_taggings.select { |t| t.tag.name == genre_name }
  end
end
