require 'page_parse/mercury_parser'

class PageImport::MercuryImporter
  class ImportWorker
    include Sidekiq::Worker

    def perform(page_download_id)
      PageImport::MercuryImporter.import_page_download(page_download_id)
    end
  end

  attr_accessor :city

  def initialize(opts={})
    @city = opts[:city] || City.find_by_slug('portland-or-us')
  end

  def self.for_mercury(opts = {})
    new opts.merge(city: City.find_by_slug('portland-or-us'))
  end

  def self.for_stranger(opts = {})
    new opts.merge(city: City.find_by_slug('seattle-wa-us'))
  end

  def self.import_page_download(page_download_id)
    page_download = PageDownload.find(page_download_id)
    source_name = page_download.data_source.name
    city_slug = case source_name
    when 'stranger'
      'seattle-wa-us'
    when 'mercury'
      'portland-or-us'
    else
      raise "Unrecognized event source name for #{self.class}: #{source_name}"
    end

    city = City.find_by_slug(city_slug)
    raise "City not found for city: #{city_slug}" unless city

    new(city: city).tap do |importer|
      importer.import_page_download(page_download)
    end
  end

  def valid?
    city or return false
    city.respond_to?(:id) or return false
    true
  end

  def import_page_download(page_download)
    file = StringIO.new(page_download.content)
    opts = {date: page_download.downloaded_at}
    import(file, opts)
    page_download.update_attributes! imported_at: Time.now.utc
  end

  def import(file, opts = {})
    raise "Invalid #{self.class}" unless valid?
    file_date = opts[:date] || date_from_file_path(file)

    PageParse::MercuryParser.new.raw_events_from_file(file).each do |raw_event|
      event = find_or_create_event(raw_event, file_date)
    end
  end

  def find_or_create_event(raw_event, file_date)
    starts_at, ends_at = EventParser.times(raw_event.time_info, date: file_date)
    time_info = raw_event.time_info
    time_info = "#{file_date.strftime('%Y-%m-%d')} #{time_info}" if file_date
    venue = find_or_create_venue(raw_event)
    artists = find_or_create_artists(raw_event)
    event = Event.where(venue_id: venue.id, starts_at: starts_at).first_or_initialize
    event.update_attributes! title:       raw_event.title[0, 255],
                             description: raw_event.description,
                             artists:     artists,
                             time_info:   time_info,
                             ends_at:     ends_at,
                             price_info:  raw_event.price_info
    event
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
    event = Venue.where(name: loc.title, city_id: city.id).first_or_initialize
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
