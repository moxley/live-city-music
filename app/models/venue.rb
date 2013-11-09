class Venue < ActiveRecord::Base
  acts_as_taggable_on :genres
  include TaggingHelper
  include GenrePointsHelper
  include GenreCalculatorCommon

  has_many :events
  has_many :genre_points, as: :target

  delegate :calculate_genre,
           :calculate_user_tagged_points,
           :calculate_name_embedded_points,
           to: :genre_calculator

  def genre_calculator
    @genre_calculator ||= GenreCalculator.new(self)
  end
end
