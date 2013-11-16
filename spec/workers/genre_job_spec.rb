require 'spec_helper'

describe GenreJob do
  include ModelHelper

  let(:venue) { Venue.create! name: 'v1' }
  let(:artist) { Artist.create! name: 'a1' }
  before(:each) do
    tagger.tag(venue, with: 'jazz', on: :genres)
    tagger.tag(artist, with: 'jazz', on: :genres)
    GenreJob.perform
  end

  it 'creates genre_point records for user-tagged venue genres' do
    gp = venue.genre_points.first
    gp.genre_id.should eq 1
    gp.genre.name.should eq 'jazz'
    gp.value.should eq 1.0
  end

  it 'creates genre_points for user-tagged artist genres' do
    gp = artist.genre_points.first
    gp.genre_id.should eq 1
    gp.value.should eq 1.0
  end
end
