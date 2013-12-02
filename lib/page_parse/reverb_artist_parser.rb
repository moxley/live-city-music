module PageParse
  class ReverbArtistParser
    attr_accessor :genres

    def initialize(opts = {})
      @dependencies = opts[:dependencies]
      @genres = []
    end

    def genres_for_artist_name(name)
      parse_artist_pages(uri_for_name(name))
    end

    private

    def parse_artist_pages(source)
      uri = get_bio_uri(source)
      @genres = get_genres(uri)
    end

    def source_to_doc(source)
      source = StringIO.new(dependencies.fetch(source)) if source.kind_of?(URI)

      if source.kind_of?(File) || source.kind_of?(StringIO)
        Nokogiri::HTML(source)
      elsif source.kind_of?(Nokogiri::HTML::Document)
        source
      else
        raise ArgumentError, "Don't know how to handle source: #{source}"
      end
    end

    def get_bio_uri(source)
      href = get_bio_href(source)
      full_url(href)
    end

    def get_genres(source)
      doc = source_to_doc(source)
      dl = doc.css('.general_info dl')
      found_genre = false
      genre = nil
      dl.children.each do |ch|
        if ch.name == 'dd' && found_genre
          genre = ch.text
          break
        elsif ch.name == 'dt' && ch.text == 'Genres:'
          found_genre = true
        end
      end

      raise ArgumentError, "Genre not found in bio" if genre.blank?

      parse_genres(genre)
    end

    def dependencies
      @dependencies ||= Dependencies.new
    end

    def full_url(href)
      URI("http://www.reverbnation.com#{href}")
    end

    class Dependencies
      def fetch(url_string)
        Net::HTTP.get(URI(url_string))
      end
    end

    def get_bio_href(source)
      # <a href="/artist_3022790/bio" class="standard_well see_more">More Info</a>
      source_to_doc(source).css('.profile_about a.see_more').first['href']
    end

    def parse_genres(genres_string)
      genres_string.split(/\s*\/\s*/)
    end

    def squash_name(name)
      name.gsub(/[^\w\d]+/, '').downcase
    end

    def uri_for_name(name)
      squashed_name = squash_name(name)
      URI("http://www.reverbnation.com/#{squashed_name}")
    end

  end
end
