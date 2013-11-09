class GenrePoint < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  belongs_to :source, polymorphic: true

  # Point types:
  # user_tag, peer_tag, peer_name

  def genre
    @genre ||= Genre.find(genre_id)
  end
end
