# Store page download from tmp/import/*.html to production
# Must be run with RAILS_ENV = production
class StoreLocalDownloadsJob
  def self.store(file_paths)
    StoreLocalDownloadsJob.new.store(file_paths)
  end

  def store(file_paths)
    file_paths = Array(file_paths)
    file_paths.each do |file_path|
      content = File.read(file_path)
      source_name, downloaded_at = parse_filename(file_path)
      data_source = DataSource.find_by_name(source_name)
      raise "Did not find event source #{source_name.inspect}" unless data_source
      page_download = PageDownload.new downloaded_at:   downloaded_at,
                                       data_source:    data_source,
                                       content:         content,
                                       env:             'production'
      page_download.set_storage_uri

      PageStorage.store(page_download)
      page_download.save!
    end
  end

  def parse_filename(file_path)
    basename = File.basename(file_path)
    m = basename.match(/^(\w+)[ \-](\d+)-(\d+)-(\d+)/)
    source_name = m[1]
    year = m[2].to_i
    month = m[3].to_i
    day = m[4].to_i
    hour = 16
    [source_name, Time.new(year, month, day, hour, 0, 0, "-07:00")]
  end
end
