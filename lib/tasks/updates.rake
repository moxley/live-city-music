require_relative '../../config/environment'

namespace :updates do
  desc 'Update artists from their data sources'
  task artists_sources: :environment do
    UpdateArtistsFromSourcesJob.perform
  end
end
