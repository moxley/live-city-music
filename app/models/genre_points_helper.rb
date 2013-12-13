class GenrePointsHelper
  attr_accessor :target

  delegate :genre_util, :genre_points, to: :target
  delegate :fuzzy_find, to: :genre_util

  def initialize(target)
    @target = target
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
    target.calculate_genre.each do |attrs|
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

  def dependencies
    @dependencies ||= Dependencies.new
  end

  private

  class Dependencies
    def find_or_initialize_genre_point(attrs)
      %i[target genre point_type source].each do |a|
        raise ArgumentError, "Missing :#{a}" if attrs[a].blank?
      end
      constraints = {target_id:   attrs[:target].id,
                     target_type: attrs[:target].class.to_s,
                     genre_id:    attrs[:genre].id,
                     point_type:  attrs[:point_type],
                     source_type: attrs[:source].class.to_s,
                     source_id:   attrs[:source].id}
      GenrePoint.where(constraints).first_or_initialize
    end

    def find_or_create_genre(name)
      genre_util.fuzzy_find(name) || Genre.create(name: name)
    end

    private

    def genre_util
      @genre_util ||= GenreUtil.new
    end
  end
end
