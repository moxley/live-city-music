class Venue < ActiveRecord::Base
  acts_as_taggable_on :genres
  include TaggingHelper
  include GenreCalculatorCommon

  has_many :events
  has_many :genre_points, as: :target

  delegate :calculate_genre,
           :calculate_user_tagged_points,
           :calculate_name_embedded_points,
           to: :genre_calculator

  delegate :calculate_and_apply_genres, to: :genre_points_helper

  def genre_calculator
    @genre_calculator ||= GenreCalculator.new(self)
  end

  def genre_points_helper
    @genre_points_helper ||= GenrePointsHelper.new(self)
  end
end
