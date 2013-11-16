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
    ar_class.all.each(&:calculate_and_apply_genres)
  end
end
