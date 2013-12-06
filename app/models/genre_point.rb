class GenrePoint < ActiveRecord::Base
  POINT_TYPES = %w(self_tag user_tag name peer_tag peer_name peer_user_tag peer_self_tag)

  belongs_to :target, polymorphic: true
  belongs_to :source, polymorphic: true
  belongs_to :genre

  validates_presence_of :target, :genre, :point_type
  validates :point_type, inclusion: {in: POINT_TYPES}
end
