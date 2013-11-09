require 'spec_helper'

describe Venue do
  subject(:venue) { Venue.create! name: 'Roxy' }
  subject(:tagger) { User.create! email: 'a@b.com' }

  it 'saves to database' do
    venue
    Venue.count.should eq 1
    Venue.first.should eq venue
  end
end
