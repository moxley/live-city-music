require 'page_parse/reverb_artist_parser'

# Updates an artist's info from reverbnation.com
class UpdateArtistReverbJob
  include Sidekiq::Worker

  sidekiq_options rate: { limit: 1, period: 2.seconds }

  def initialize(opts = {})
    @options = opts
  end

  def dependencies
    @dependencies ||= @options[:dependencies] || Dependencies.new
  end

  def perform(artist_id)
    Artist.transaction do
      artist = dependencies.find_artist(artist_id)
      genres = dependencies.get_genres(artist.name)
      source = dependencies.reverb_source
      artist.add_genres! source, genres

      JobRun.create! target: artist, job_type: 'update_artist_from_source', sub_type: 'reverb', status: 'success'
    end
  end

  private

  class Dependencies
    def get_genres(artist_name)
      PageParse::ReverbArtistParser.get_artist_genres(artist_name)
    end

    def find_artist(artist_id)
      Artist.find(artist_id)
    end

    def reverb_source
      DataSource.find_by_name('reverb') or raise ArgumentError, "DataSource 'reverb' not found"
    end
  end
end
