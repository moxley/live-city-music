require "net/http"
require "uri"

class PageCollector
  attr_accessor :mail

  # https://devcenter.heroku.com/articles/scheduler
  # heroku run bin/job
  def self.collect
    new.collect
  end

  def collect
    store_downloads
    email_downloads
  end

  def store_downloads
    downloads.map do |page_download|
      # Store to S3
      PageStorage.store(page_download)

      page_download.downloaded_at = Time.now.utc
      page_download.save!
    end
  end

  def initialize_page_download(url_info, content)
    event_source = find_or_initialize_event_source(url_info[:name], url_info[:url])

    PageDownload.new event_source: event_source, set_storage_uri: true, content: content
  end

  def find_or_initialize_event_source(name, url)
    event_source = EventSource.where(name: name).first_or_initialize
    event_source.url ||= url
    event_source
  end

  def email_downloads
    out = StringIO.new
    out.puts "PageCollector\n"
    out.puts "Downloads:"

    downloads.each do |page_download|
      out.puts "  #{page_download.storage_uri}: #{page_download.content.length}"
    end
    body = out.string

    mail = create_mail(body)

    send_mail(mail)
  end

  def event_sources
    EventSource.all
  end

  def downloads
    @downloads ||= event_sources.map do |u|
      response = http_fetch(u[:url])
      initialize_page_download(u, response.body)
    end
  end

  def create_mail(body)
    downloads = self.downloads
    @mail = Mail.new do
      to      'moxley.stratton@gmail.com'
      from    'moxley.stratton@gmail.com'
      subject 'Live music downloads'
      body    body
      downloads.each do |page_download|
        add_file filename: page_download.email_filename, content: page_download.content
      end
    end
  end

  def http_fetch(uri_string)
    Net::HTTP.get_response(URI.parse(uri_string))
  end

  def send_mail(mail)
    mail.deliver!
  end
end
