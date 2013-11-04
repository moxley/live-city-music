require_relative '../../config/environment'

desc 'calculate genre points for artists and venues'
namespace :calculate do
  task genres: :environment do
    GenreJob.perform
  end
end
