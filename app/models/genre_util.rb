class GenreUtil
  attr_accessor :target, :dependencies

  delegate :calculate_and_apply_genres,
           :self_tagged_genre_points,
           :user_tagged_genre_points,
           :add_genres!,
           :add_user_tagged_genres!,
           to: :points_helper

  def initialize(target)
    @target = target
  end

  def calculate_name_embedded_points
    genres_in_name(target.name).map do |name|
      {point_type: 'name', genre_name: name, value: 0.5, source: target}
    end
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

  def dependencies
    @dependencies ||= Dependencies.new(target)
  end

  private

  class Dependencies
    attr_accessor :target
    delegate :genre_util, to: :target

    def initialize(target)
      @target = target
    end

    def find_or_initialize_genre_point(attrs)
      %i[target genre point_type source].each do |a|
        raise ArgumentError, "Missing :#{a}" if attrs[a].blank?
      end
      constraints = {target:      attrs[:target],
                     genre_id:    attrs[:genre].id,
                     point_type:  attrs[:point_type],
                     source_type: attrs[:source].class.to_s,
                     source_id:   attrs[:source].id}
      GenrePoint.where(constraints).first_or_initialize do |gp|
        gp.target ||= attrs[:target]
      end
    end

    def find_or_create_genre(name)
      genre_util.fuzzy_find(name) || Genre.create(name: name)
    end
  end
end
