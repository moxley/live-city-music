require 'spec_helper'

describe Artist do
  it 'saves' do
    a = Artist.create name: 'The Good Music Group'
    Artist.count.should eq 1
    Artist.first.should eq a
  end

  describe '#add_genres!' do
    subject(:artist) do
      stub_model(Artist).tap do |artist|
        artist.stub(genre_points_helper: genre_points_helper(artist))
        artist.genre_util.points_helper.dependencies = dependencies
      end
    end
    def genre_points_helper(artist)
      GenrePointsHelper.new(artist).tap do |helper|
        helper.stub(dependencies: dependencies)
      end
    end
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

    it 'calls #find_or_initialize_genre_point for each new genre' do
      genres = []
      dependencies.should_receive(:find_or_initialize_genre_point).exactly(3).times do |attrs|
        attrs[:target].should eq artist
        attrs[:genre].should be_present
        genres << attrs[:genre]
        attrs[:point_type].should eq 'self_tag'
        genre_point
      end
      dependencies.stub(:find_or_create_genre) { |name| genres_by_name[name] }
      source = DataSource.create! name: 's1', url: 'http://s1.com/'
      returned_genres = artist.add_genres! source, genre_names
      Set.new(genres.map { |g| g.name }).should eq Set.new(genre_names)
      returned_genres.should eq genres
    end

    it 'skips invalid genre names' do
      artist = stub_model(Artist) # without stubbed dependencies
      source = stub_model(DataSource)
      genres = artist.add_genres! source, ['genre0123456789012345678901234567890123456789']
      genres.should be_blank
    end
  end
end
