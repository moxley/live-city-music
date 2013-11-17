require 'spec_helper'

describe GenreUtil do
  describe '#genres_in_name' do
    subject(:genre_util) { GenreUtil.new }

    before(:each) do
      Genre.create! name: 'jazz'
    end

    it 'returns an empty result when the artist or vendor name contains no gender name' do
      genre_util.genres_in_name('A Volcano').should eq []
    end

    it 'finds a genre name from an artist or vendor name' do
      genre_util.genres_in_name('Ron Steen Jazz Jam').should eq ['jazz']
    end
  end
end
