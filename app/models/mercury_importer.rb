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

  def self.import_page_download(page_download_id)
    page_download = PageDownload.find(page_download_id)
    source_name = page_download.event_source.name
    city = case source_name
    when 'stranger'
      'Seattle'
    when 'mercury'
      'Portland'
    else
      raise "Unrecognized event source name for #{self.class}: #{source_name}"
    end

    new(city: city).tap do |importer|
      importer.import_page_download(page_download)
    end
  end

  def import_page_download(page_download)
    file = StringIO.new(page_download.content)
    opts = {date: page_download.downloaded_at}
    import(file, opts)
    page_download.update_attributes! imported_at: Time.now.utc
  end

  def import(file, opts = {})
    date = opts[:date] || date_from_file_path(file)

    MercuryParser.new.raw_events_from_file(file).each do |raw_event|
      starts_at, ends_at = EventParser.times(raw_event.time_info, date: date)
      time_info = raw_event.time_info
      time_info = "#{date.strftime('%Y-%m-%d')} #{time_info}" if date
      event = Event.create title: raw_event.title,
                           venue: find_or_create_venue(raw_event),
                           description: raw_event.description,
                           artists: find_or_create_artists(raw_event),
                           time_info: time_info,
                           starts_at: starts_at,
                           ends_at: ends_at,
                           price_info: raw_event.price_info
    end
  end

  def date_from_file_path(file)
    if file.try(:path) && (m = file.path.match(/((\d+)-)?(\d+)-(\d+)/))
      year = (m[2] || Time.now.year).to_i
      month = m[3].to_i
      day = m[4].to_i
      Date.new(year, month, day)
    else
      nil
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
