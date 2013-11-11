require_relative '../../config/environment'

namespace :pages do
  desc 'Download web pages from all event sources'
  task download: :environment do
    PageCollector.collect
  end
end
