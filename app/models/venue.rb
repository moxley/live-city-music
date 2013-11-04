class Venue < ActiveRecord::Base
  acts_as_taggable_on :genres

  has_many :events
  has_many :genre_points, as: :target

  class GenreCalculator
    attr_accessor :venue, :points_by_genre

    delegate :genre_taggings,
             :name,
             to: :venue

    def initialize(venue)
      @venue = venue
      @points_by_genre = Hash.new(0.0)
    end

    def calculate
      @points_by_genre = Hash.new(0.0)
      calc_user_tags
      calculate_venue_name
      self
    end

    def calc_user_tags
      genre_taggings.each do |tagging|
        points_by_genre[tagging.tag.name] += 1.0
      end
    end

    def calculate_venue_name
      GenreUtil.genres_in_name(name).each do |genre_name|
        points_by_genre[genre_name] += 0.5
      end
    end
  end

  def genre_calculator
    @genre_calculator ||= GenreCalculator.new(self).calculate
  end

  def genre_points_by_name
    genre_calculator.calculate.points_by_genre
  end
end
