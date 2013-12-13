require 'spec_helper'

describe Venue::DerivedGenreCalculator do
  include ModelHelper

  describe '#calculate_genre' do
    it 'is one point of 0.5 for a name-embedded genre' do
      Genre.create! name: 'jazz'
      venue('The Jazz House')
      points = venue.genre_calculator.calculate_genre
      points.length.should eq 1
      expect(points[0]).to eq(point_type: 'name', genre_name: 'jazz', value: 0.5, source: venue)
    end
  end  
end
