class Venue::GenreCalculator
  attr_accessor :venue

  delegate :name,
           :genre_taggings,
           to: :venue

  delegate :calculate_user_tagged_points,
           :calculate_name_embedded_points_for,
           to: :genre_calculator_common

  def initialize(venue)
    @venue = venue
  end

  def calculate_genre
    calculate_user_tagged_points +
    calculate_name_embedded_points
  end

  def calculate_name_embedded_points
    calculate_name_embedded_points_for(venue)
  end

  def genre_calculator_common
    @genre_calculator_common ||= GenreCalculatorCommon.new(self)
  end
end
