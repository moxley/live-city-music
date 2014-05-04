require 'spec_helper'

describe BrowseController do
  let(:genre) { create(:genre) }

  describe '#genres' do
    it 'renders the genres page' do
      get :genres, city_slug: 'portland-or-us'
    end
  end

  describe '#artists_by_genre' do
    it 'renders the artists by genre page' do
      get :artists_by_genre, city_slug: 'portland-or-us', genre_id: genre.id
    end
  end
end
