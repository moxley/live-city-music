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
      obj.calculate_genre.each do |attrs|
        genre = Genre.find_by_name(attrs[:genre_name])
        gp = GenrePoint.where(target:     obj,
                              genre_id:   genre.id,
                              point_type: attrs[:point_type],
                              source:     attrs[:source]).
                        first_or_initialize
        gp.value = attrs[:value]
        gp.save!
      end
    end
  end
end
