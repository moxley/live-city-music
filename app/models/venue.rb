class Venue < ActiveRecord::Base
  acts_as_taggable on: :user_genres
end
