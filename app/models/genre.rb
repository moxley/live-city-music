require 'page_parse/styles_of_music_parser'

class Genre < ActiveRecord::Base
  NAME_EMBEDDED_GENRES = %w(jazz rock latin country)

  validates :name, length: { maximum: 40 }

  def self.import_from_file(file)
    parser = PageParse::StylesOfMusicParser.new(file)
    parser.styles.each do |style_name|
      Genre.where(name: style_name).first_or_create
    end
  end
end
