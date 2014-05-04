class SlugsWithStates < ActiveRecord::Migration
  def change
    City.all.each do |city|
      city.name = city.name # Forces regeneration of slug
      city.save!
    end
  end
end
