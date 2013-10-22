require 'spec_helper'

describe MercuryImporter do
  subject(:importer) { MercuryImporter.new }

  it 'integrates', integration: true do
    file = File.new('spec/fixtures/html/mercury.html')
    importer.import(file)

    Event.count.should eq 7

    event = Event.where(title: 'Lents 1st Annual Oktoberfest: Wilkinson Blades, Race of Strangers, Garden Goat and Beaver Boogie Band').first
    event.should be_present
    event.description.should include 'A lot of Germany in a little bit of Lents'

    venue = event.venue
    venue.should be_present
    venue.name.should eq 'Eagle Eye Tavern'
    venue.city.should eq 'Portland'
    venue.address_1.should eq '5836 SE 92nd'
    venue.phone.should eq '503-774-2141'
  end

  it 'calls Artist.create' do
    html = %(<html><body>
      <div class="EventListing">
        <div class="listing">
          <h3>
            <span class="longOnly">
              <div class="FeaturesIcons">
                <a href="/portland/EventSearch?feature=Readers%20Pick" class="FeaturesIcons_readers_pick" title="Readers Pick">
                <span>Readers Pick</span>
              </a>
              </div>
            </span>
            <a href="http://www.portlandmercury.com/portland/lents-1st-annual-oktoberfest/Event?oid=10556451">
              Lents 1st Annual Oktoberfest:
              Wilkinson Blades, Race of Strangers, Garden Goat and Beaver Boogie Band
            </a>
          </h3>
        </div>

        <div class="listingLocation">
          <a href="http://www.portlandmercury.com/portland/eagle_eye_tavern/Location?oid=7139747">
            Eagle Eye Tavern
          </a> 
          <img src="/images/icons/phone.gif" alt="phone" />
          503-774-2141<br />
          5836 SE 92nd<br />
          <span class="locationRegion"><a href="http://www.portlandmercury.com/portland/EventSearch?neighborhood=38241">Southeast</a></span>
        </div>

        <div class="descripTxt">
          A lot of Germany in a little bit of Lents
        </div>
      </div>
      </body></html>)
    file = StringIO.new(html)
    Event.should receive(:create)
    Artist.should receive(:create)
    importer.import(file)
  end
end
