module PageParse
  class ReverbArtistParser
    attr_accessor :genres

    def initialize(opts = {})
      @dependencies = opts[:dependencies]
      @genres = []
    end

    def get_artist_pages(artist_name)
      @genres = []

      uri = uri_for_name(artist_name)
      artist_html = dependencies.fetch(uri)
      return false unless artist_html

      g = get_genres_from_artist(StringIO.new(artist_html))
      return false unless g

      @genres = g

      true
    end

    private

    def get_genres_from_artist(source)
      doc = doc_from_source(source)
      genre_string = doc.css('.profile_genre').text

      return nil if genre_string.blank?

      parse_genres(genre_string)
    end

    def doc_from_source(source)
      if source.kind_of?(File) || source.kind_of?(StringIO)
        Nokogiri::HTML(source)
      elsif source.kind_of?(Nokogiri::HTML::Document)
        source
      else
        raise ArgumentError, "Don't know how to handle source: #{source}"
      end
    end

    def dependencies
      @dependencies ||= Dependencies.new
    end

    def full_uri(href)
      URI("http://www.reverbnation.com#{href}")
    end

    class Dependencies
      def fetch(uri)
        res = Net::HTTP.get_response(URI(uri))
        return nil unless res.is_a?(Net::HTTPSuccess)
        res.body
      end
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
