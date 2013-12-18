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

  def self.for_today
    # Start of day: 12am
    # Time Zone: Pacific
    for_date(beginning_of_day)
  end

  def self.beginning_of_day
    tz = ActiveSupport::TimeZone.new('Pacific Time (US & Canada)')
    Time.now.in_time_zone(tz).beginning_of_day
  end

  def self.for_date(date)
    ids = ungrouped_by_date(date).select('genres.id').group('genres.id').pluck(:id)
    where(id: ids).order('name')
  end

  def self.ungrouped_by_today
    ungrouped_by_date(beginning_of_day)
  end

  def self.ungrouped_by_date(date)
    query = joins({genre_points: {artist: {artists_events: {event: :venue}}}}).
      where('events.starts_at > ?', date)
  end
end
