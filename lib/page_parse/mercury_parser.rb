require "anemone"

module PageParse
  class MercuryParser
    remove_const(:RawLocation) if defined?(RawLocation)
    class RawLocation < Struct.new(:title, :address_1, :phone)
    end

    remove_const(:RawEvent) if defined?(RawEvent)
    class RawEvent < Struct.new(:title, :time_info, :location, :description, :price_info)
    end

    def raw_events
      @raw_events ||= begin
        #url = 'http://www.portlandmercury.com/portland/EventSearch?eventCategory=807942&eventSection=807941&narrowByDate=2013-09-28'
        #url = 'http://www.moxleydata.com/'
        url = 'http://localhost:8000/mercury.html'
        Anemone.crawl(url) do |anemone|
          titles = []
          anemone.on_every_page do |page|
            process_doc(page.doc)
          end
          anemone.after_crawl { puts titles.compact.sort }
          anemone.focus_crawl { |page| [] }
        end
        @raw_events
      end
    end

    # file: File
    def raw_events_from_file(file)
      doc = Nokogiri::HTML(file)
      process_doc(doc)
    end

    # doc: nokogiri document
    def process_doc(doc)
      @raw_events ||= begin
        @raw_events = []
        doc.css('.EventListing').each do |listing_el|
          @raw_events << parse_event(listing_el)
        end
        @raw_events
      end
    end

    # private

    def parse_event(listing_el)
      event_title, time_info, price_info = parse_header(listing_el)
      location = parse_location(listing_el)
      description = listing_el.css('.descripTxt').text.to_s.strip
      RawEvent.new event_title, time_info, location, description, price_info
    end

    def parse_header(listing_el)
      header_el = listing_el.css('.listing')
      event_title = nil
      header_el.css('h3 > a').each do |a|
        event_title = a.text.strip.gsub(/\s+/, ' ')
      end
      time_info = nil
      h3 = nil
      price_info = nil
      # h3, time_info, br, price_info
      pattern = [{tag: 'h3'}, {text: true}, {tag: 'br'}, {text: true}]
      match = []
      iter = PutbackIterator.new(header_el.children)
      while el = iter.next
        p = pattern[match.length] or break
        if p[:tag] && el.element? && el.name == p[:tag]
          match << el.text
          matched_text = false
        elsif p[:text] && el.text?
          tmp_text = [el.text]
          while el = iter.next
            if el.text?
              tmp_text << el.text
            elsif el
              iter.put_back
              break
            end
          end
          match << tmp_text.join.strip
        end
      end
      time_info = match[1]
      price_info = match[3]
      [event_title, time_info, price_info]
    end

    class PutbackIterator
      attr_accessor :index

      def initialize(items)
        @items = items
        @index = 0
      end

      def next
        item = @items[@index]
        @index += 1
        item
      end

      def put_back
        @index -= 1
      end
    end

    def parse_location(listing_el)
      loc_title = listing_el.css('.listingLocation > a')[0].text
      phone = nil
      address_1 = nil
      listing_el.css('.listingLocation').children.each do |el|
        if el.text?
          text = el.text.strip
          if phone.nil? && text =~ /\d+-\d+/
            phone = text
          elsif address_1.nil? && text =~ /\d+/
            address_1 = text
          end
        end
      end
      RawLocation.new loc_title, address_1, phone
    end
  end
end
