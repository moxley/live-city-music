class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :tagger, :class_name => 'User', polymorphic: true
end
