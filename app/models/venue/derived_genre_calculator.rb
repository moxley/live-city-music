class Venue::DerivedGenreCalculator
  attr_accessor :venue

  delegate :name,
           :genre_taggings,
           :genre_util,
           to: :venue

  delegate :calculate_name_embedded_points,
           to: :genre_util

  def initialize(venue)
    @venue = venue
  end

  def calculate_genre
    calculate_name_embedded_points
  end
end
