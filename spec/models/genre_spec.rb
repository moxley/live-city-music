require 'spec_helper'

describe Genre do
  include ModelHelper

  describe '.import_from_file' do
    it 'creates genres' do
      expect {
        Genre.import_from_file(list_of_styles_file)
      }.to change(Genre, :count)
    end
  end

  describe '.for_today' do
    it 'returns expected records' do
      event = create(:event)
      artist = create(:artist)
      event.artists << artist
      create(:genre_point, target: artist)
      city = event.venue.city

      res = Genre.for_today(city.slug)
      expect(res).to be_present
    end
  end
end
