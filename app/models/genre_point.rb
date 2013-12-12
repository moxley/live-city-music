class GenrePoint < ActiveRecord::Base
  POINT_TYPES = %w(self_tag
                   user_tag
                   name
                   peer_self_tag
                   peer_user_tag
                   peer_name)

  belongs_to :target, polymorphic: true
  belongs_to :source, polymorphic: true
  belongs_to :genre

  validates_presence_of :target, :genre, :point_type
  validates :point_type, inclusion: {in: POINT_TYPES}

  def genre_name
    genre.name
  end
end
