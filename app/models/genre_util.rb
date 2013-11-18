class GenreUtil
  def genres_in_name(name)
    name.split.map(&:parameterize).select do |n|
      fuzzy_find(n)
    end
  end

  def ordered_genres
    @ordered_genres ||= Genre.order("LENGTH(name) DESC")
  end

  def genres_by_name_key
    @genres_by_name_key ||= ordered_genres.inject({}) do |hash, genre|
      hash[genre.name.parameterize] = genre
      hash
    end
  end

  def fuzzy_find(name)
    normalized_name = name.parameterize
    genres_by_name_key[name]
  end
end
