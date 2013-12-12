module TaggingHelper
  def genre_self_taggings
    GenrePoint.where(target: self, point_type: 'self_tag')
  end

  def genre_taggings
    Tagging.includes(:tag).where(taggable_type: self.class.name, taggable_id: id)
  end

  def genre_taggings_by_name(genre_name)
    genre_taggings.select { |t| t.tag.name == genre_name }
  end
end
