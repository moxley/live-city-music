require 'spec_helper'

describe Artist do
  it 'saves' do
    a = Artist.create name: 'The Good Music Group'
    Artist.count.should eq 1
    Artist.first.should eq a
  end

  describe '#add_genres!' do
    subject(:artist) { stub_model(Artist, dependencies: dependencies) }
    let(:dependencies) { double(:dependencies) }
    let(:genre_names) { ['g1', 'g2', 'g3'] }
    let(:genres_by_name) do
      genre_names.inject({}) do |h, name|
        h[name] = stub_model(Genre, name: name)
        h
      end
    end
    let(:genre_point) do
      double(:genre_point).tap do |gp|
        gp.should_receive(:update_attributes!).with(value: 2.0).exactly(3).times
      end
    end

    it 'calls find_or_build_genre_point for each new genre' do
      genres = []
      dependencies.should_receive(:find_or_build_genre_point).exactly(3).times do |attrs|
        attrs[:target].should eq artist
        attrs[:genre].should be_present
        genres << attrs[:genre]
        attrs[:point_type].should eq 'self'
        genre_point
      end
      dependencies.stub(:find_or_create_genre) { |name| genres_by_name[name] }
      artist.add_genres! 'reverb', genre_names
      Set.new(genres.map { |g| g.name }).should eq Set.new(genre_names)
    end
  end

  describe 'Dependencies', integration: true do
    describe '#create_genre_point'
    describe '#find_or_create_genre'
  end
end
