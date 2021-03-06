require 'spec_helper'

describe PageImport::MercuryImporter do
  include ModelHelper

  let(:portland) { City.create(name: 'Portland', state: 'OR', country: 'US') }
  let(:seattle) { City.create(name: 'Seattle', state: 'WA', country: 'US') }

  describe '.import_page_download' do
    let(:downloaded_at) { Time.new(2013, 10, 31).utc }
    let(:page_download) do
      PageDownload.create! downloaded_at: downloaded_at, data_source: data_source
    end
    let(:data_source) do
      DataSource.create! name: 'mercury', url: 'http://example.com/mercury'
    end

    it 'creates events' do
      portland
      PageDownload.any_instance.stub(content: page_content_with_single_event)

      expect {
        PageImport::MercuryImporter.import_page_download(page_download.id)
      }.to change(Event, :count).by(1)
      event = Event.last
      event.starts_at.year.should eq 2013
      event.starts_at.month.should eq 10
      event.starts_at.day.should eq 31

      page_download.reload.imported_at.should be_present
    end

    it 'does not duplicate events when run a second time' do
      portland
      PageDownload.any_instance.stub(content: page_content_with_single_event)

      expect {
        PageImport::MercuryImporter.import_page_download(page_download.id)
        PageImport::MercuryImporter.import_page_download(page_download.id)
      }.to change(Event, :count).by(1)
    end
  end

  describe '.for_mercury' do
    it 'instantiates a valid MercuryImporter' do
      portland
      importer = PageImport::MercuryImporter.for_mercury
      expect(importer).to be_valid
    end
  end

  describe '.for_stranger' do
    it 'instantiates a valid MercuryImporter' do
      seattle
      importer = PageImport::MercuryImporter.for_stranger
      expect(importer).to be_valid
    end
  end

  describe '#import' do
    subject(:importer) { PageImport::MercuryImporter.new }

    it 'integrates', integration: true do
      portland
      Timecop.freeze(Date.new(2013, 9, 1)) do
        file = File.new('spec/fixtures/html/mercury.html')
        importer.import(file)

        Event.count.should eq 7

        event = Event.where(title: 'Lents 1st Annual Oktoberfest: Wilkinson Blades, Race of Strangers, Garden Goat and Beaver Boogie Band').first
        event.should be_present
        event.description.should include 'A lot of Germany in a little bit of Lents'
        event.time_info.should eq 'Sun., Sept. 29, 12 p.m.'
        event.starts_at.month.should eq 9
        event.starts_at.day.should eq 29
        event.starts_at.year.should eq 2013
        event.price_info.should eq '$5'

        venue = event.venue
        venue.should be_present
        venue.name.should eq 'Eagle Eye Tavern'
        venue.city.should eq portland
        venue.address_1.should eq '5836 SE 92nd'
        venue.phone.should eq '503-774-2141'
      end
    end

    it 'finds artists using Artist.find_or_create_by and attaches them to the event' do
      portland
      html = "<html><body>" + File.read('spec/fixtures/html/single_event.html') + "</body></html>"
      file = StringIO.new(html)
      file.stub(path: "mercury 10-20.html")
      artists_by_name = {
        'Wilkinson Blades'   => double(:artist1),
        'Race of Strangers'  => double(:artist2),
        'Garden Goat'        => double(:artist3),
        'Beaver Boogie Band' => double(:artist4),
      }
      Event.any_instance.should_receive(:update_attributes!).once do |attrs|
        Set.new(attrs[:artists]).should eq Set.new(artists_by_name.values)
      end
      Artist.stub(:find_or_create_by) { |h| artists_by_name[h[:name]] }
      importer.import(file)
    end
  end
end
