module ModelHelper
  def tagger
    @tagger ||= User.create email: 'tagger@a.com', password: 'pass0123!@#$'
  end

  def venue(name = 'v1')
    @venue ||= Venue.create name: name
  end

  def page_content
    "<html><body>foo</body></html>"
  end

  def page_content_with_events
    File.read("spec/fixtures/html/mercury.html")
  end

  def page_content_with_single_event
    File.read("spec/fixtures/html/single_event.html")
  end

  def list_of_styles_file
    File.new('spec/fixtures/html/list_of_styles.html')
  end
end
