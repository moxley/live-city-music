module EventParser
  PLACEHOLDER_ARTIST_NAMES = %(guests friends)

  def self.artist_names(event_title)
    names = event_title[/^([^:]*:\s*)?(.*)$/, 2] # Remove special event title

    names = names.split(',').map(&:strip)

    if (last_names = names.last.split(/ and /)) && last_names.length > 1
      names.pop
      names += last_names
    end

    names = names.reject do |n|
      PLACEHOLDER_ARTIST_NAMES.include?(n.pluralize.downcase)
    end
  end

  def self.times(time_string, opts = {})
    source_date = opts[:date]
    return [source_date, nil] unless time_string =~ /\d/
    
    [parse_time(time_string, source_date), nil]
  end

  def self.parse_time(time_string, source_date)
    t = Time.parse(time_string)
    return t unless source_date

    d = source_date
    Time.new(d.year, d.month, d.day, t.hour, t.min)
  end
end
