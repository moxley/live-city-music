class PageDownload < ActiveRecord::Base
  attr_accessor :body
  belongs_to :event_source
end
