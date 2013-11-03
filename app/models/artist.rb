class Artist < ActiveRecord::Base
  acts_as_taggable_on :genres
  attr_accessor :genre_points

  has_many :events

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

    hash.map do |genre, value|
      GenrePoint.new(genre, value)
    end
  end

  def genre_points
    @genre_points ||= calc_genre_points
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
