module PageParse
  class StylesOfMusicParser
    attr_accessor :file

    def initialize(file)
      @file = file
    end

    def styles
      doc = Nokogiri::HTML(file)

      doc.css('#mw-content-text > ul > li > a:first-child').map do |a_el|
        style_name = a_el.text.strip
        next if style_name =~ /^section/i
        style_name
      end.compact
    end
  end
end
