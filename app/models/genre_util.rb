module GenreUtil
  extend self

  def genres_in_name(name)
    all_genres = %w(jazz).map(&:downcase)
    name.downcase.split.select do |n|
      n.in?(all_genres)
    end
  end
end
