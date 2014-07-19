require 'spec_helper'

describe ArtistsController do
  render_views

  describe "#show" do
    it "shows the artist details" do
      artist = create(:artist)
      get :show, id: artist.id
    end
  end
end
