require 'spec_helper'

describe GenrePointsHelper do
  describe 'Dependencies', integration: true do
    let(:artist)       { Artist.create! name: 'a1' }
    let(:genre)        { Genre.create! name: 'g1' }
    let(:source)       { DataSource.create! name: 's1', url: 'http://s1.com/' }
    let(:attrs)        { {target: artist, genre: genre, point_type: 'self_tag', source: source} }
    let(:genre_point)  { GenrePoint.create!(attrs) }
    let(:helper)       { GenrePointsHelper.new(artist) }
    let(:dependencies) { helper.dependencies }

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
