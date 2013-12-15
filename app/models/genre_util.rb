class GenreUtil
  attr_accessor :target, :dependencies

  delegate :genre_points, to: :target

  delegate :calculate_genre, to: :derived_genre_calculator

  def initialize(target)
    @target = target
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

  def genre_value_by_name(genre_name)
    genre = Genre.find_by_name(genre_name)
    value = 0.0
    target.genre_points.each do |gp|
      if gp.genre_id == genre.id
        value += gp.value
      end
    end
    value
  end

  def calculate_and_apply_genres
    calculate_genre.each do |attrs|
      genre = fuzzy_find(attrs[:genre_name])
      raise "No genre defined for #{attrs[:genre_name].inspect}" unless genre
      gp = GenrePoint.where(target:     target,
                            genre_id:   genre.id,
                            point_type: attrs[:point_type],
                            source:     attrs[:source]).
                      first_or_initialize
      gp.value = attrs[:value]
      gp.save!
      target.genre_points << gp
    end
  end

  def self_tagged_genre_points
    genre_points.where(point_type: 'self_tag').includes(:genre)
  end

  def user_tagged_genre_points
    genre_points.where(point_type: 'user_tag').includes(:genre)
  end

  def add_genres!(source, names, point_type='self_tag', value=2.0)
    genres = []
    names = Array(names)
    names.each do |name|
      genre = dependencies.find_or_create_genre(name)
      if genre.valid?
        gp = dependencies.find_or_initialize_genre_point(target: target, genre: genre, point_type: point_type, source: source)
        gp.update_attributes!(value: value)
        genres << genre
      end
    end
    genres
  end

  def add_user_tagged_genres!(user, names)
    add_genres!(user, names, 'user_tag', 1.0)
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
