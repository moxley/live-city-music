require 'spec_helper'
require 'page_parse/styles_of_music_parser'

describe PageParse::StylesOfMusicParser do
  include ModelHelper

  subject(:parser) { PageParse::StylesOfMusicParser.new(list_of_styles_file) }

  describe '#styles' do
    it 'returns an list of style names' do
      styles = parser.styles
      styles.should be_kind_of(Array)
      styles.length.should > 0
      styles.first.should eq '2-step garage'
      styles.last.should eq 'Futurepop'
    end
  end
end
