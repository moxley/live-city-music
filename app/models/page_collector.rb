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

      PageImport::MercuryImporter.delay.import_page_download(page_download.id)
    end
  end

  def initialize_page_download(url_info, content)
    data_source = find_or_initialize_data_source(url_info[:name], url_info[:url])

    PageDownload.new data_source: data_source, set_storage_uri: true, content: content
  end

  def find_or_initialize_data_source(name, url)
    data_source = DataSource.where(name: name).first_or_initialize
    data_source.url ||= url
    data_source
  end

  def email_downloads
    out = StringIO.new
    out.puts "PageCollector\n"
    out.puts "Host: #{ENV['HOST']}"
    out.puts "Downloads:"

    downloads.each do |page_download|
      out.puts "  #{page_download.storage_uri}: #{page_download.content.length}"
    end
    body = out.string

    mail = create_mail(body)

    send_mail(mail)
  end

  def data_sources
    DataSource.where(name: %w(mercury stranger))
  end

  def downloads
    @downloads ||= data_sources.map do |u|
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
