require 'page_parse/styles_of_music_parser'

class Genre < ActiveRecord::Base
  NAME_EMBEDDED_GENRES = %w(jazz rock latin country)

  validates :name, length: { maximum: 40 }

  has_many :genre_points

  def self.import_from_file(file)
    parser = PageParse::StylesOfMusicParser.new(file)
    parser.styles.each do |style_name|
      Genre.where(name: style_name).first_or_create
    end
  end

  def self.for_today(city_slug)
    # Start of day: 12am
    # Time Zone: Pacific
    for_date(city_slug, beginning_of_day)
  end

  def self.beginning_of_day
    tz = ActiveSupport::TimeZone.new('Pacific Time (US & Canada)')
    Time.now.in_time_zone(tz).beginning_of_day
  end

  def self.for_date(city_slug, date)
    ids = ungrouped_by_date(city_slug, date).select('genres.id').group('genres.id').pluck(:id)
    where(id: ids).order('name')
  end

  def self.ungrouped_by_today(city_slug)
    ungrouped_by_date(city_slug, beginning_of_day)
  end

  def self.ungrouped_by_date(city_slug, date)
    query = joins({genre_points: {artist: {artists_events: {event: {venue: :city}}}}}).
      where('cities.slug = ? AND events.starts_at > ?', city_slug, date)
  end
end
