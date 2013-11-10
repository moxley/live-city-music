class PageDownload < ActiveRecord::Base
  attr_accessor :body
  belongs_to :event_source

  def source_name
    event_source.name
  end

  def email_filename
    date = (downloaded_at || Time.now).strftime('%Y-%m-%d')
    "#{source_name}-#{date}.html"
  end
end
