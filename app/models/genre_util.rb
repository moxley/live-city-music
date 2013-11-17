class GenreUtil
  def genres_in_name(name)
    name.split.map(&:parameterize).select do |n|
      n.in?(all_parameterized_genres)
    end
  end

  def all_parameterized_genres
    @all_normalized_genres ||= Genre.order("LENGTH(name) DESC").pluck(:name).map(&:parameterize)
  end
end
