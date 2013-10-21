require 'spec_helper'

describe Venue do
  it 'saves to database' do
    v = Venue.create name: 'Roxy'
    Venue.count.should eq 1
    Venue.first.should eq v
  end
end
