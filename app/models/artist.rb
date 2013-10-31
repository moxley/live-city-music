class Artist < ActiveRecord::Base
  acts_as_taggable_on :user_genres, :peer_genres, :venue_genres, :name_genres

  has_many :events

  def played_with
    Artist.
      joins('JOIN artists_events ae ON ae.artist_id = artists.id AND ae.artist_id != %d' % id).
      joins('JOIN artists_events ae2 ON ae2.artist_id = %d
             AND ae2.event_id = ae.event_id' % id)
  end
end
