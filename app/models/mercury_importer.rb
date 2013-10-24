class MercuryImporter
  attr_accessor :city

  def initialize(opts={})
    @city = opts[:city] || 'Portland'
  end

  def self.for_mercury(opts = {})
    new opts.merge(city: 'Portland')
  end

  def self.for_stranger(opts = {})
    new opts.merge(city: 'Seattle')
  end

  def import(file)
    MercuryParser.new.raw_events_from_file(file).each do |raw_event|
      event = Event.create title: raw_event.title,
                           venue: find_or_create_venue(raw_event),
                           description: raw_event.description,
                           artists: find_or_create_artists(raw_event)
    end
  end

  def find_or_create_venue(raw_event)
    loc = raw_event.location
    event = Venue.where(name: loc.title, city: city).first_or_initialize
    event.attributes = {address_1: loc.address_1, phone: loc.phone}
    event.save!
    event
  end

  def find_or_create_artists(raw_event)
    names = EventParser.artist_names(raw_event.title)
    names.map do |name|
      Artist.find_or_create_by(name: name)
    end
  end
end
