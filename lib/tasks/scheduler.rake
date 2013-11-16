desc "Collects predetermined web pages and emails them"
task :collect_pages => :environment do
  puts "Collecting pages..."
  PageCollector.collect
  puts "done."
end

desc "Runs genre calculation job"
task calculate_genres: :environment do
  puts "Firing off genre calculation jobs..."
  GenreJob.perform
  puts "done."
end
