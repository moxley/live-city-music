require 'spec_helper'

describe GenreJob do
  include ModelHelper

  let(:venue) { Venue.create! name: 'v1' }
  let(:artist) { Artist.create! name: 'a1' }
  let(:jazz) { Genre.create! name: 'Jazz' }

  context 'user tags' do
    before(:each) do
      jazz
      tagger.tag(venue, with: 'jazz', on: :genres)
      tagger.tag(artist, with: 'jazz', on: :genres)
      GenreJob.perform
    end

    it 'creates genre_point records for user-tagged venue genres' do
      gp = venue.genre_points.first
      gp.genre.name.should eq 'Jazz'
      gp.value.should eq 1.0
    end

    it 'creates genre_points for user-tagged artist genres' do
      gp = artist.genre_points.first
      gp.value.should eq 1.0
    end
  end

  it "create a genre_point of 0.5 for a venue with \"Jazz\" in it's name" do
    jazz
    venue = Venue.create! name: 'Ivories Jazz Lounge and Restaurant'
    GenreJob.perform
    gp = venue.genre_points.first
    gp.should be_present
    gp.genre.name.should eq 'Jazz'
    gp.value.should eq 0.5
  end
end
