class Venue < ActiveRecord::Base
  acts_as_taggable_on :user_genres
end
