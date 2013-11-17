require 'page_parse/styles_of_music_parser'

class Genre < ActiveRecord::Base
  GENRES = [
    {id: 1, name: 'jazz'},
    {id: 2, name: 'country'},
    {id: 3, name: 'funk'},
  ]

  def self.import_from_file(file)
    parser = PageParse::StylesOfMusicParser.new(file)
    parser.styles.each do |style_name|
      Genre.create! name: style_name
    end
  end
end
