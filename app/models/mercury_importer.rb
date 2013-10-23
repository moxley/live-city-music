class MercuryImporter
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
    event = Venue.where(name: loc.title, city: 'Portland').first_or_initialize
    event.attributes = {address_1: loc.address_1, phone: loc.phone}
    event.save!
    event
  end

  def find_or_create_artists(raw_event)
    names = raw_event.title[/^([^:]*:\s*)?(.*)$/, 2] # Remove special event name
    if names.include?(',')
      # Replace last 'and' with comma
      names.gsub!(/ and /, ',')
    end
    names = names.split(',').map(&:strip)
    names.map do |name|
      Artist.find_or_create_by(name: name)
    end
  end
end
