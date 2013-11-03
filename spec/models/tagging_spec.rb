require 'spec_helper'

describe 'tagging' do
  describe 'tag point value' do
    let(:artist) { Artist.create! name: 'a1' }
    let(:tagger) { User.create! email: 'a@b.com' }
    let(:peer_artist) do
      Artist.create!(name: 'a2').tap do |a2|
        event = Event.create! title: 'e1'
        event.artists << artist
        event.artists << a2
      end
    end

    it 'is 1.0 point for a genre tag' do
      tagger.tag artist, with: 'funk', on: :user_genres
      artist.genre_value('funk').should eq 1.0
    end

    it "is 0.5 point for a peer's genre tag" do
      artist.save!
      tagger.tag peer_artist, with: 'funk', on: :user_genres
      artist.calc_genre_points
      artist.genre_value('funk').should eq 0.5
    end

    it "is 1.5 points for the artist's genre tag and a peer's genre tag" do
      tagger.tag artist, with: 'funk', on: :user_genres
      tagger.tag peer_artist, with: 'funk', on: :user_genres
      artist.genre_value('funk').should eq 1.5
    end
  end
end
