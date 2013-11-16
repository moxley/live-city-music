require_relative '../../config/environment'

desc 'import event data from HTML files'
task :import do
  Dir.glob('tmp/imports/*.html').each do |path|
    importer = if path =~ /stranger/
      MercuryImporter.for_stranger
    else
      MercuryImporter.for_mercury
    end
    importer.import(File.new(path))
  end
end
