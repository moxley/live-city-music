class PageDownload < ActiveRecord::Base
  attr_accessor :content
  belongs_to :event_source

  def source_name
    event_source.name
  end

  def email_filename
    date = (downloaded_at || Time.now.utc).strftime('%Y-%m-%dT%H')
    "#{source_name}-#{date}.html"
  end

  def calculate_storage_uri
    path_1 = Time.now.utc.strftime('%Y/%m/%d/%H')
    filename = "#{path_1}/#{source_name}.html"

    storage_uri = "page_downloads/#{filename}"
  end

  def set_storage_uri=(_)
    self.storage_uri ||= calculate_storage_uri
  end
end
