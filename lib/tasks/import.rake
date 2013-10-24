require_relative '../../config/environment'

desc 'import HTML from a web page'
task :import do
  Dir.glob('tmp/imports/*.html').each do |path|
    if path =~ /stranger/
      importer = MercuryImporter.for_stranger
    else
      importer = MercuryImporter.for_mercury
    end
    month, day = path[/(\d+-\d+)/, 1].split('-')
    importer.import(File.new(path))
  end
end
