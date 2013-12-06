# Updates an artist's info from reverbnation.com
class ReverbUpdatesJob
  include Sidekiq::Worker

  def initialize(opts = {})
    @options = opts
  end

  def dependencies
    @dependencies ||= @options[:dependencies] || Dependencies.new
  end

  def perform(artist_id)
    artist = dependencies.find_artist(artist_id)
    artist.add_genres! :reverb, dependencies.get_genres(artist.name)
  end

  private

  class Dependencies
    def get_genres(artist_name)
      PageParse::ReverbArtistParser.get_artist_genres(artist_name)
    end

    def find_artist(artist_id)
      Artist.find(artist_id)
    end
  end
end
