require 'spec_helper'

describe GenreUtil do
  subject(:genre_util) { GenreUtil.new(double('artist')) }

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

  describe 'Dependencies', integration: true do
    let(:artist)       { Artist.create! name: 'a1' }
    let(:genre)        { Genre.create! name: 'g1' }
    let(:source)       { DataSource.create! name: 's1', url: 'http://s1.com/' }
    let(:attrs)        { {target: artist, genre: genre, point_type: 'self_tag', source: source} }
    let(:genre_point)  { GenrePoint.create!(attrs) }
    let(:genre_util)   { artist.genre_util }
    let(:dependencies) { genre_util.dependencies }

    describe '#find_or_initialize_genre_point' do
      subject(:find_or_initialize_genre_point) { dependencies.find_or_initialize_genre_point(attrs) }

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
        g = dependencies.find_or_create_genre('g1')
        g.should eq genre
      end

      it 'creates a genre if a match is not found' do
        expect {
          g = dependencies.find_or_create_genre('g1')
          g.name.should eq 'g1'
        }.to change(Genre, :count).by(1)
      end
    end
  end
end
