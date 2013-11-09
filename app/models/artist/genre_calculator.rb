class Artist::GenreCalculator
  attr_accessor :artist, :points_by_genre, :points_by_genre_name_and_point_type

  include GenreCalculatorCommon

  delegate :name,
           :genre_taggings,
           :played_with,
           :venues,
           to: :artist

  def initialize(artist)
    @artist = artist
    @genre_points = Hash.new(0.0)
  end

  def calculate_genre
    points = []

    points += calculate_user_tagged_points
    points += calculate_name_embedded_points
    points += calculate_points_from_peers

    points
  end

  def calculate_name_embedded_points
    calculate_name_embedded_points_for(artist)
  end

  def calculate_points_from_peers
    points = []
    played_with.each do |peer|
      # user-tagged genre
      points += peer.calculate_user_tagged_points.map do |p|
        {point_type: 'peer_user_tag', genre_name: p[:genre_name], value: 0.5, source: peer}
      end

      # artist name-embedded genre
      points += peer.calculate_name_embedded_points.map do |p|
        {point_type: 'peer_name', genre_name: p[:genre_name], value: 0.25, source: peer}
      end
    end
    points
  end
end
