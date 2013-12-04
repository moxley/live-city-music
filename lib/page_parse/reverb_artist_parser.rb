module PageParse
  class ReverbArtistParser
    attr_accessor :genres

    def initialize(opts = {})
      @dependencies = opts[:dependencies]
      @genres = []
    end

    def get_artist_pages(artist_name)
      uri = uri_for_name(artist_name)
      artist_html = dependencies.fetch(uri)
      return false unless artist_html

      bio_uri = get_bio_uri(StringIO.new(artist_html))
      return false unless bio_uri

      bio_html = dependencies.fetch(bio_uri)
      return false unless bio_html

      g = get_genres(StringIO.new(bio_html))
      return false unless g

      @genres = g

      true
    end

    private

    def source_to_doc(source)
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
      full_uri(href)
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

      return false if genre.blank?

      parse_genres(genre)
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
