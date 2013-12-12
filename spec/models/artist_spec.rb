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
      returned_genres = artist.add_genres! double('source'), genre_names
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

  describe 'Dependencies', integration: true do
    subject(:artist)  { Artist.create! name: 'a1' }
    let(:genre)       { Genre.create! name: 'g1' }
    let(:source)      { DataSource.create! name: 's1', url: 'http://s1.com/' }
    let(:attrs)       { {target: artist, genre: genre, point_type: 'self_tag', source: source} }
    let(:genre_point) { GenrePoint.create!(attrs) }

    describe '#find_or_initialize_genre_point' do
      subject(:find_or_initialize_genre_point) { artist.dependencies.find_or_initialize_genre_point(attrs) }

      it 'builds a GenrePoint if not found' do
        should be_kind_of(GenrePoint)
        should be_new_record
      end

      it 'finds matching GenrePoint' do
        genre_point
        should eq genre_point
      end

      describe 'required attributes' do
        subject do
          expect { find_or_initialize_genre_point }
        end

        it 'does not raise error if all attributes are present' do
          subject.not_to raise_error
        end

        it 'raises ArgumentError if :target attribute is missing' do
          attrs.delete(:target)
          subject.to raise_error(ArgumentError)
        end

        it 'raise ArgumentError if :genre attribute is missing' do
          attrs.delete(:genre)
          subject.to raise_error(ArgumentError)
        end

        it 'raise ArgumentError if :point_type attribute is missing' do
          attrs.delete(:point_type)
          subject.to raise_error(ArgumentError)
        end

        it 'raise ArgumentError if :source attribute is missing' do
          attrs.delete(:source)
          subject.to raise_error(ArgumentError)
        end
      end
    end

    describe '#find_or_create_genre' do
      let(:genre) { Genre.create! name: 'G1' }

      it 'finds a matching genre, using fuzzy matching' do
        genre
        g = artist.dependencies.find_or_create_genre('g1')
        g.should eq genre
      end

      it 'creates a genre if a match is not found' do
        expect {
          g = artist.dependencies.find_or_create_genre('g1')
          g.name.should eq 'g1'
        }.to change(Genre, :count).by(1)
      end
    end
  end
end
