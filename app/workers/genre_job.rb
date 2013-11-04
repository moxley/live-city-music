class GenreJob
  def self.perform
    new.perform
  end

  def perform
    perform_on_venues
    perform_on_artists
  end

  def perform_on_venues
    perform_on(Venue)
  end

  def perform_on_artists
    perform_on(Artist)
  end

  def perform_on(ar_class)
    ar_class.all.each do |obj|
      obj.genre_points_by_name.each do |genre_name, value|
        genre = Genre.find_by_name(genre_name)
        gp = GenrePoint.where(target: obj, genre_id: genre.id).first_or_initialize
        gp.value = value
        gp.save!
      end
    end
  end
end
