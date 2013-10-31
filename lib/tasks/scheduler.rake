desc "Collects predetermined web pages and emails them"
task :collect_pages => :environment do
  puts "Collecting pages..."
  PageCollector.collect
  puts "done."
end
