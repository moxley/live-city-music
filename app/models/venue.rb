class Venue < ActiveRecord::Base
  acts_as_taggable_on :genres

  has_many :events
end
