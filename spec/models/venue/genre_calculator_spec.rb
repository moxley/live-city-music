require 'spec_helper'

describe Venue::GenreCalculator do
  include ModelHelper

  describe '#calculate_genre' do
    it 'is one point of 1.0 for a user tagged genre' do
      tagger.tag venue, with: 'funk', on: 'user_genres'
      points = venue.genre_calculator.calculate_genre
      points.length.should eq 1
      expect(points[0]).to eq(point_type: 'user_tag', genre_name: 'funk', value: 1.0, source: tagger)
    end

    it 'is one point of 0.5 for a name-embedded genre' do
      Genre.create! name: 'jazz'
      venue('The Jazz House')
      points = venue.genre_calculator.calculate_genre
      points.length.should eq 1
      expect(points[0]).to eq(point_type: 'name', genre_name: 'jazz', value: 0.5, source: venue)
    end
  end  
end
