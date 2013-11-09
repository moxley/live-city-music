module GenreUtil
  extend self

  def genres_in_name(name)
    all_genres = Genre::GENRES.map { |g| g[:name].downcase }
    name.downcase.split.select do |n|
      n.in?(all_genres)
    end
  end
end
