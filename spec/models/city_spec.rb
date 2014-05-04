require 'spec_helper'

describe City do
  describe '#name=' do
    it 'sets slug to the parameterized version of #name' do
      city = City.new
      city.name = 'Portland'
      city.slug.should eq 'portland'
    end
  end
end
