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

  def self.collect
    new.collect
  end

  def collect
    # https://devcenter.heroku.com/articles/scheduler
    # heroku run bin/job

    out = StringIO.new
    out.puts "PageCollector\n"
    out.puts "Downloads:"
    downloads.each do |df|
      out.puts "  #{df[:filename]}: #{df[:content].length}"
    end
    body = out.string

    mail = create_mail(body, downloads)

    send_mail(mail)
  end

  def urls
    URLS
  end

  def downloads
    urls.map do |u|
      response = http_fetch(u[:url])
      date = Time.now.strftime('%Y-%m-%d')
      { filename: "#{u[:name]}-#{date}.html", content: response.body }
    end
  end

  def create_mail(body, downloads)
    @mail = Mail.new do
      to      'moxley.stratton@gmail.com'
      from    'moxley.stratton@gmail.com'
      subject 'Live music downloads'
      body    body
      downloads.each { |df| add_file df }
    end
  end

  def http_fetch(uri_string)
    Net::HTTP.get_response(URI.parse(uri_string))
  end

  def send_mail(mail)
    mail.deliver!
  end
end
