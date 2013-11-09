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
end
