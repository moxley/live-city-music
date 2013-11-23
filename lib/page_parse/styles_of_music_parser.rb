module PageParse
  class StylesOfMusicParser
    attr_accessor :file

    def initialize(file)
      @file = file
    end

    def styles
      doc = Nokogiri::HTML(file)

      doc.css('#mw-content-text > ul > li > a:first-child').map do |a_el|
        style_name = clean_name(a_el.text)
        next if style_name =~ /^section/i
        style_name
      end.compact
    end

    def clean_name(name)
      name.strip.sub(/( period in)? music/i, '')
    end
  end
end
