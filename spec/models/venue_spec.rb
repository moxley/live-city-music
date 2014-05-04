require 'spec_helper'

describe Venue do
  subject(:venue) { Venue.create! name: 'Roxy', city: city }
  let(:tagger)    { User.create! email: 'a@b.com' }
  let(:city)      { City.create! name: 'Portland', state: 'OR', country: 'US' }

  it 'saves to database' do
    venue
    Venue.count.should eq 1
    Venue.first.should eq venue
  end
end
