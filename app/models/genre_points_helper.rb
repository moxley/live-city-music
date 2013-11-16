module GenrePointsHelper
  def genre_value_by_name(genre_name)
    genre = Genre.find_by_name(genre_name)
    value = 0.0
    genre_points.each do |gp|
      if gp.genre_id == genre.id
        value += gp.value
      end
    end
    value
  end

  def calculate_and_apply_genres
    calculate_genre.each do |attrs|
      genre = Genre.find_by_name(attrs[:genre_name])
      gp = GenrePoint.where(target:     self,
                            genre_id:   genre.id,
                            point_type: attrs[:point_type],
                            source:     attrs[:source]).
                      first_or_initialize
      gp.value = attrs[:value]
      gp.save!
      genre_points << gp
    end
  end
end
