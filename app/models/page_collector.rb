require "net/http"
require "uri"

class PageCollector
  attr_accessor :mail

  URLS = [
    {
      name: :mercury,
      url: "http://www.portlandmercury.com/portland/EventSearch?eventCategory=807942&eventSection=807941&narrowByDate=Today",
      #url: "http://localhost:8000/mercury.html"
    },
    {
      name: :stranger,
      url: "http://www.thestranger.com/gyrobase/EventSearch?eventSection=3208279&narrowByDate=Today",
      #url: "http://localhost:8000/stranger.html"
    },
    # {
    #   name: :nelcentro,
    #   url: "http://www.nelcentro.com/blog/jazz/"
    # },
    # {
    #   name: :duffsgarage,
    #   url: "http://www.duffsgarage.com/"
    # }
  ]

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
    downloads.map do |df|
      page_download = initialize_page_download(df)

      # Store to S3
      PageStorage.store(page_download)

      page_download.downloaded_at = Time.now
      page_download.save!
    end
  end

  def initialize_page_download(df)
    event_source = find_or_create_event_source(df[:name], df[:url])

    path_1 = Time.now.strftime('%Y/%m/%d')
    filename = "#{path_1}/#{df[:name]}.html"

    storage_uri = "page_downloads/#{filename}"
    PageDownload.new event_source: event_source, storage_uri: storage_uri
  end

  def find_or_create_event_source(name, url)
    event_source = EventSource.where(name: name).first_or_initialize
    event_source.url ||= url
    event_source.save! if event_source.new_record? || event_source.changed?
    event_source
  end

  def email_downloads
    out = StringIO.new
    out.puts "PageCollector\n"
    out.puts "Downloads:"

    dls = downloads.map do |df|
      df.merge filename: email_filename(df[:name], df[:timestamp])
    end

    dls.each do |df|
      out.puts "  #{df[:filename]}: #{df[:content].length}"
    end
    body = out.string

    mail = create_mail(body, dls)

    send_mail(mail)
  end

  def urls
    URLS
  end

  def downloads
    @downloads ||= urls.map do |u|
      response = http_fetch(u[:url])
      { name: u[:name], url: u[:url], timestamp: Time.now, content: response.body }
    end
  end

  # TODO remove
  def email_filename(source_name, timestamp)
    date = timestamp.strftime('%Y-%m-%d')
    "#{source_name}-#{date}.html"
  end

  def create_mail(body, downloads)
    @mail = Mail.new do
      to      'moxley.stratton@gmail.com'
      from    'moxley.stratton@gmail.com'
      subject 'Live music downloads'
      body    body
      downloads.each do |df|
        add_file df
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
