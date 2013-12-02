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
  let(:bio_file)       { File.new("spec/fixtures/html/the_stubborn_lovers_bio.html") }
  let(:bio_url_string) { "http://www.reverbnation.com/artist_3022790/bio" }
  let(:bio_uri)        { URI(bio_url_string) }
  let(:genres)         { ['Americana', 'Alt Country', 'Roots'] }

  before do
    dependencies.should_receive(:fetch).with(artist_uri).and_return(artist_file.read)
    dependencies.should_receive(:fetch).with(bio_uri).and_return(bio_file.read)
  end

  describe '#genres_for_artist_name' do
    it 'returns genres for artist name' do
      genres = parser.genres_for_artist_name(artist_name)
    end
  end
end
