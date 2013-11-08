class Artist::GenreCalculator
  attr_accessor :artist, :points_by_genre, :points_by_genre_name_and_point_type

  delegate :name,
           :genre_taggings,
           :played_with,
           :venues,
           to: :artist

  def initialize(artist)
    @artist = artist
    @genre_points = Hash.new(0.0)
  end

  def genre_points
    points_by_genre_name_and_point_type.map do |(genre_name, type), value|
      genre = Genre.find_by_name(genre_name)
      GenrePoint.new(genre_id: genre.id, value: value, type: type)
    end
  end

  def calculate
    @points_by_genre_name_and_point_type = Hash.new(0.0)
    calc_user_tags
    calc_peers
    calc_artist_name
    calc_venues
    self
  end

  def calc_user_tags
    genre_taggings.each do |t|
      points_by_genre_name_and_point_type[[t.tag.name, 'tag']] += 1.0
    end
  end

  def calc_peers
    played_with.each do |peer_artist|
      peer_artist.genre_taggings.each do |t|
        points_by_genre_name_and_point_type[[t.tag.name, 'peer']] += 0.5
      end
    end
  end

  def calc_artist_name
    GenreUtil.genres_in_name(name).each do |genre_name|
      points_by_genre_name_and_point_type[[genre_name, 'name']] += 0.5
    end
  end

  def calc_venues
    venues.each do |v|
      v.genre_list.each do |genre_name|
        points_by_genre_name_and_point_type[[genre_name, 'venue']] += 0.25
      end
    end
  end
end
