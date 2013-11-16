class EventSource < ActiveRecord::Base
  has_many :page_downloads

  validates_presence_of :name, :url
end
