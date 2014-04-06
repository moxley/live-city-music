class PopulateEventSources < ActiveRecord::Migration
  URLS = [
    {
      name: :mercury,
      url: "http://www.portlandmercury.com/portland/EventSearch?eventCategory=807942&eventSection=807941&narrowByDate=Today",
      #url: "http://localhost:8000/mercury.html"
    },
    {
      name: :stranger,
      url: "http://www.thestranger.com/gyrobase/EventSearch?eventSection=3208279&narrowByDate=Today",
      #url: "http://localhost:8000/stranger.html"
    }
  ]

  class EventSource < ActiveRecord::Base
  end

  def up
    return if Rails.env == 'test'
    URLS.each do |u|
      event_source = EventSource.where(name: u[:name]).first_or_initialize
      event_source.url = u[:url]
      event_source.save!
    end
  end

  def down
  end
end
