class GenrePoint < ActiveRecord::Base
  belongs_to :target, polymorphic: true

  def genre
    @genre ||= Genre.find(genre_id)
  end
end
