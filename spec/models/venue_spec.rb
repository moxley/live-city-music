require 'spec_helper'

describe Venue do
  subject(:venue) { Venue.create! name: 'Roxy' }
  subject(:tagger) { User.create! email: 'a@b.com' }

  it 'saves to database' do
    venue
    Venue.count.should eq 1
    Venue.first.should eq venue
  end

  describe 'genre points' do
    it 'is 1.0 for a user-tagged genre' do
      venue
      tagger.tag(venue, with: 'jazz', on: :genres)
      venue.genre_points_by_name['jazz'].should eq 1.0
    end
  end
end
