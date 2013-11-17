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
end
