class GenreUtil
  def genres_in_name(name)
    name_words = name.split.map(&:parameterize)
    Genre::NAME_EMBEDDED_GENRES.map(&:parameterize).select do |n|
      name_words.include?(n)
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
    genres_by_name_key[name.parameterize]
  end
end
