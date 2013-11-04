class GenreJob
  def perform
    perform_on_venues
    perform_on_artists
  end

  def perform_on_venues
    Venue.all.each do |venue|
      venue.genre_points_by_name.each do |genre_name, value|
        genre = Genre.find_by_name(genre_name)
        gp = GenrePoint.where(target: venue, genre_id: genre.id).first_or_initialize
        gp.value = value
        gp.save!
      end
    end
  end

  def perform_on_artists
    Artist.all.each do |artist|
      artist.genre_points_by_name.each do |genre_name, value|
        genre = Genre.find_by_name(genre_name)
        gp = GenrePoint.where(target: artist, genre_id: genre.id).first_or_initialize
        gp.value = value
        gp.save!
      end
    end
  end
end
