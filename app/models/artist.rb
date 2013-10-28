class Artist < ActiveRecord::Base
  acts_as_taggable on: :user_genres, :peer_genres, :venue_genres, :name_genres
end
