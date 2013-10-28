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
    if time_string =~ /^[^\d]*$/
      [source_date, nil]
    else
      parsed_time = Time.parse(time_string)
      if source_date
        d = source_date
        p = parsed_time
        parsed_time = Time.new(d.year, d.month, d.day, p.hour, p.min)
      end
      [parsed_time, nil]
    end
  end
end
