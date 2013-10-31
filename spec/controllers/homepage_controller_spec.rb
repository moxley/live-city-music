require 'spec_helper'

describe HomepageController do
  render_views

  describe 'index' do
    it 'responds' do
      get :index
      response.body.should include 'Bandlist'
    end
  end
end
