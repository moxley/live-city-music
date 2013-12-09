require 'spec_helper'

describe GenreUtil do
  subject(:genre_util) { GenreUtil.new }

  describe '#genres_in_name' do
    before(:each) do
      Genre.create! name: 'jazz'
    end

    it 'returns an empty result when the artist or vendor name contains no gender name' do
      genre_util.genres_in_name('A Volcano').should eq []
    end

    it "returns an empty result when the name contains a genre that is not indicitive of the artist or venue's genre" do
      genre_util.genres_in_name('Tango Alpha Tango').should eq []
    end

    it 'finds a genre name from an artist or vendor name' do
      genre_util.genres_in_name('Ron Steen Jazz Jam').should eq ['jazz']
    end
  end

  describe '#fuzzy_find' do
    it 'finds jazz' do
      Genre.create! name: 'Jazz'
      genre_util.fuzzy_find('jazz').should be_kind_of(Genre)
    end
  end
end
