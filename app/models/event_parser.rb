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

  def self.times(time_string)
    if time_string =~ /^[^\d]*$/
      [nil, nil]
    else
      [Time.parse(time_string), nil]
    end
  end
end
