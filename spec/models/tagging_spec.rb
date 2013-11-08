require 'spec_helper'

describe 'tagging' do
  describe 'tag point value' do
    def create_artist(name); Artist.create!(name: name); end
    let(:artist) { create_artist 'a1' }
    let(:tagger) { User.create! email: 'a@b.com' }
    let(:venue) { Venue.new name: "Al's Den" }
    let(:event) { Event.create! title: 'e1', venue: venue }
    let(:peer_artist) do
      create_artist('a2').tap do |a2|
        event.artists << artist
        event.artists << a2
      end
    end

    it 'is 0.0 point by default' do
      artist.genre_points_by_genre_name('funk').should eq 0.0
    end

    it 'is 1.0 point for a genre tag' do
      tagger.tag artist, with: 'funk', on: :user_genres
      artist.genre_points_by_genre_name('funk').should eq 1.0
    end

    it "is 0.5 point for a peer's genre tag" do
      artist.save!
      tagger.tag peer_artist, with: 'funk', on: :user_genres
      artist.genre_points_by_genre_name('funk').should eq 0.5
    end

    it "is 1.5 points for the artist's genre tag and a peer's genre tag" do
      tagger.tag artist, with: 'funk', on: :user_genres
      tagger.tag peer_artist, with: 'funk', on: :user_genres
      artist.genre_points_by_genre_name('funk').should eq 1.5
    end

    it 'is 0.5 points for having a genre name within the artist name' do
      artist = create_artist('Ron Steen Jazz Jam')
      artist.genre_points_by_genre_name('jazz').should eq 0.5
    end

    it 'is 0.25 points for playing at a venue tagged with a genre' do
      venue.genre_list << 'jazz'
      event.artists << artist
      artist.genre_points_by_genre_name('jazz').should eq 0.25
    end
  end
end
