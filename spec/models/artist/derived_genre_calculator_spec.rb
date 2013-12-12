require 'spec_helper'

describe Artist::DerivedGenreCalculator do
  include ModelHelper

  def create_artist(name); Artist.create!(name: name); end
  let(:artist) { create_artist 'a1' }
  let(:venue) { Venue.new name: "Al's Den" }
  let(:event) { Event.create! title: 'e1', venue: venue }
  def peer_artist(name = 'a2')
    @peer_artist ||= begin
      create_artist(name).tap do |a2|
        event.artists << artist
        event.artists << a2
      end
    end
  end

  def point_item_should_match(point_item, hash)
    point_item.slice(*hash.keys).should eq hash
  end

  describe 'genre calculation' do
    it 'is one point of 1.0 for a user genre tag' do
      tagger.tag artist, with: 'funk', on: :user_genres
      point_values = artist.calculate_genre
      point_values.length.should eq 1
      point_item_should_match point_values[0],
                              { value:      1.0,
                                point_type: 'user_tag',
                                genre_name: 'funk',
                                source:     tagger }
    end

    it "is one point of 0.5 for a peer's genre tag" do
      tagger.tag peer_artist, with: 'funk', on: :user_genres
      point_values = artist.calculate_genre
      point_values.length.should eq 1
      point_item_should_match point_values[0],
                              { value:      0.5,
                                point_type: 'peer_user_tag',
                                genre_name: 'funk',
                                source:     peer_artist }
    end

    it "is one point of 1.0 for a user tag and one point of 0.5 for a peer's user tag" do
      tagger.tag artist, with: 'funk', on: :user_genres
      tagger.tag peer_artist, with: 'funk', on: :user_genres
      point_values = artist.calculate_genre
      point_values.length.should eq 2

      user_tag_pv = point_values.detect { |pv| pv[:point_type] == 'user_tag' }
      user_tag_pv.should be_present
      point_item_should_match user_tag_pv,
                              { value: 1.0,
                                genre_name: 'funk',
                                source: tagger}

      peer_user_tag_pv = point_values.detect { |pv| pv[:point_type] == 'peer_user_tag' }
      peer_user_tag_pv.should be_present
      point_item_should_match peer_user_tag_pv,
                              { value:      0.5,
                                genre_name: 'funk',
                                source:     peer_artist}
    end

    it "is one point of 0.5 for a artist name embedded genre" do
      artist = create_artist('Ron Steen Jazz Jam')
      point_values = artist.calculate_genre
      point_values.length.should eq 1

      pv = point_values[0]
      point_item_should_match pv,
                              { value:      0.5,
                                point_type: 'name',
                                genre_name: 'jazz',
                                source:     artist}
    end

    it "is one point of 0.25 for a peer artist name embedded genre" do
      peer_artist('Richard Colvin & the NY Jazz Quartet')
      point_values = artist.calculate_genre
      point_values.length.should eq 1

      pv = point_values[0]
      point_item_should_match pv,
                              { value:      0.25,
                                point_type: 'peer_name',
                                genre_name: 'jazz',
                                source:     peer_artist}
    end
  end
end
