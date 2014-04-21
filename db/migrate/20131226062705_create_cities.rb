class CreateCities < ActiveRecord::Migration
  class City < ActiveRecord::Base
  end

  def up
    create_table :cities do |t|
      t.string :name
      t.string :slug
      t.string :state, length: 2
      t.string :country, length: 2
    end

    add_index :cities, [:slug, :state, :country], unique: true

    unless Rails.env.test?
      City.create name: 'Portland', slug: 'portland', state: 'OR', country: 'US'
      City.create name: 'Seattle', slug: 'seattle', state: 'WA', country: 'US'
      City.create name: 'Sacramento', slug: 'sacramento', state: 'CA', country: 'US'
      City.create name: 'San Francisco', slug: 'san-francisco', state: 'CA', country: 'US'
      City.create name: 'Los Angeles', slug: 'los-angeles', state: 'CA', country: 'US'
    end
  end

  def down
    drop_table :cities
  end
end
