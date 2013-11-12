class PageDownload < ActiveRecord::Base
  attr_accessor :content, :env
  belongs_to :event_source

  def source_name
    event_source.name
  end

  def email_filename
    date = (downloaded_at || Time.now.utc).strftime('%Y-%m-%dT%H')
    "#{source_name}-#{date}.html"
  end

  def calculate_storage_uri
    time_path = (downloaded_at || Time.now).utc.strftime('%Y/%m/%d/%H')
    filename = "#{source_name}.html"

    "#{env}/page_downloads/#{time_path}/#{filename}"
  end

  def env
    @env ||= Rails.env
  end

  def set_storage_uri=(_)
    self.set_storage_uri
  end

  def set_storage_uri
    self.storage_uri ||= calculate_storage_uri
  end
end
