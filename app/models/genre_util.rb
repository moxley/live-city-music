class GenreUtil
  attr_accessor :target

  delegate :calculate_and_apply_genres,
           :self_tagged_genre_points,
           :user_tagged_genre_points,
           :add_genres!,
           :add_user_tagged_genres!,
           :dependencies, # TODO remove
           to: :points_helper

  def initialize(target)
    @target = target
  end

  def genres_in_name(name)
    name_words = name.split.map(&:parameterize)
    Genre::NAME_EMBEDDED_GENRES.map(&:parameterize).select do |n|
      name_words.include?(n)
    end
  end

  def ordered_genres
    @ordered_genres ||= Genre.order("LENGTH(name) DESC")
  end

  def genres_by_name_key
    @genres_by_name_key ||= ordered_genres.inject({}) do |hash, genre|
      hash[genre.name.parameterize] = genre
      hash
    end
  end

  def fuzzy_find(name)
    genres_by_name_key[name.parameterize]
  end

  def points_helper
    @points_helper ||= GenrePointsHelper.new(target)
  end

  def derived_genre_calculator
    @derived_genre_calculator ||= target.class.const_get(:DerivedGenreCalculator).new(target)
  end
end
