require_relative '../../config/environment'

namespace :import do
  desc 'import event data from HTML files'
  task :pages do
    Dir.glob('tmp/imports/*.html').each do |path|
      importer = if path =~ /stranger/
        MercuryImporter.for_stranger
      else
        MercuryImporter.for_mercury
      end
      importer.import(File.new(path))
    end
  end

  desc 'import musical genres from HTML files'
  task :genres do
    Dir.glob('tmp/list_of_styles*.html') do |path|
      Genre.import_from_file(File.new(path))
    end
  end
end
