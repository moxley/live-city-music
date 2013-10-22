require 'spec_helper'

describe Artist do
  it 'saves' do
    a = Artist.create name: 'The Good Music Group'
    Artist.count.should eq 1
    Artist.first.should eq a
  end
end
