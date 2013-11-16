require 'spec_helper'

describe MercuryImporter do
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
        MercuryImporter.import_page_download(page_download.id)
      }.to change(Event, :count).by(1)
      event = Event.last
      event.starts_at.year.should eq 2013
      event.starts_at.month.should eq 10
      event.starts_at.day.should eq 31

      page_download.reload.imported_at.should be_present
    end
  end
end
