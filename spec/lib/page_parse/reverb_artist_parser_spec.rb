require 'spec_helper'
require 'page_parse/reverb_artist_parser'

module PageParse
end

describe PageParse::ReverbArtistParser do
  subject(:parser)     { PageParse::ReverbArtistParser.new(dependencies: dependencies) }
  let(:dependencies)   { double(:dependencies) }
  let(:artist_name)    { "The Stubborn Lovers" }
  let(:artist_uri)     { URI("http://www.reverbnation.com/thestubbornlovers") }
  let(:artist_file)    { File.new("spec/fixtures/html/the_stubborn_lovers.html") }
  let(:genres)         { ['Americana', 'Alt Country', 'Roots'] }

  before do
    dependencies.should_receive(:fetch).with(artist_uri).and_return(artist_file.read)
  end

  describe '#get_artist_pages' do
    it 'returns true if the page exists' do
      res = parser.get_artist_pages(artist_name)
      res.should be_true
      parser.genres.should eq genres
    end
  end
end
