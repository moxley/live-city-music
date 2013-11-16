require 'spec_helper'

describe PageImport::MercuryImporter do
  include ModelHelper

  describe '.import_page_download' do
    let(:downloaded_at) { Time.new(2013, 10, 31).utc }
    let(:page_download) do
      PageDownload.create! downloaded_at: downloaded_at, event_source: event_source
    end
    let(:event_source) do
      EventSource.create! name: 'mercury', url: 'http://example.com/mercury'
    end

    it 'creates events' do
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
  end

  describe '#import' do
    subject(:importer) { PageImport::MercuryImporter.new }

    it 'integrates', integration: true do
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
      venue.city.should eq 'Portland'
      venue.address_1.should eq '5836 SE 92nd'
      venue.phone.should eq '503-774-2141'
    end

    it 'calls Artist.create' do
      html = "<html><body>" + File.read('spec/fixtures/html/single_event.html') + "</body></html>"
      file = StringIO.new(html)
      def file.path
        "mercury 10-20.html"
      end
      Event.should receive(:create)
      names = []
      Artist.stub(:find_or_create_by) { |h| names << h[:name] }
      importer.import(file)
      names.should eq ['Wilkinson Blades', 'Race of Strangers', 'Garden Goat', 'Beaver Boogie Band']
    end
  end
end
