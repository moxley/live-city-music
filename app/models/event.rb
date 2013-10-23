class Event < ActiveRecord::Base
  belongs_to :venue
  has_many :artists_events
  has_many :artists, through: :artists_events
end
