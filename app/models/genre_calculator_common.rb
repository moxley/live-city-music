module GenreCalculatorCommon
  def calculate_user_tagged_points
    genre_taggings.map do |t|
      {point_type: 'user_tag', genre_name: t.tag.name, value: 1.0, source: t.tagger}
    end
  end

  def calculate_name_embedded_points_for(obj)
    GenreUtil.genres_in_name(obj.name).map do |name|
      {point_type: 'name', genre_name: name, value: 0.5, source: obj}
    end
  end
end
