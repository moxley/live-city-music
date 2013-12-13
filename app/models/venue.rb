class Venue < ActiveRecord::Base
  acts_as_taggable_on :genres
  include TaggingHelper

  has_many :events
  has_many :genre_points, as: :target

  delegate :calculate_genre,
           :calculate_name_embedded_points,
           to: :genre_calculator

  delegate :calculate_and_apply_genres,
           :self_tagged_genre_points,
           :user_tagged_genre_points,
           :add_genres!,
           :add_user_tagged_genres!,
           to: :genre_points_helper

  def genre_calculator
    @genre_calculator ||= DerivedGenreCalculator.new(self)
  end

  def genre_points_helper
    @genre_points_helper ||= GenrePointsHelper.new(self)
  end

  def genre_util
    @genre_util ||= GenreUtil.new
  end
end
