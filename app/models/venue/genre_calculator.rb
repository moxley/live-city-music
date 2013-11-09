class Venue::GenreCalculator
  attr_accessor :venue
  include GenreCalculatorCommon

  delegate :name,
           :genre_taggings,
           to: :venue

  def initialize(venue)
    @venue = venue
  end

  def calculate_genre
    points = []
    points += calculate_user_tagged_points
    points += calculate_name_embedded_points
    points
  end

  def calculate_name_embedded_points
    calculate_name_embedded_points_for(venue)
  end
end
