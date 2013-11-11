require 'spec_helper'

describe PageCollector do
  let(:response) { OpenStruct.new(body: '<html>foo</html>') }
  let(:collector) { PageCollector.new }
  let(:url_def) { {name: :mercury, url: 'http://foo.com/bar.html'} }

  it 'fetches web pages and delivers them via email' do
    collector.stub(urls: [url_def])
    collector.should_receive(:http_fetch).at_least(:once) { response }
    date = Time.now.utc.strftime('%Y-%m-%dT%H')
    collector.should_receive(:send_mail) do |mail|
      mail.to.should eq ['moxley.stratton@gmail.com']
      mail.attachments.map(&:filename).should include "mercury-#{date}.html"
    end

    PageStorage.stub(store: true)

    collector.collect
  end

  it 'creates PageDownloads for every downloaded page' do
    collector.stub(http_fetch: response, send_mail: true, urls: [url_def])
    PageStorage.stub(store: true)

    expect {
      collector.collect
    }.to change(PageDownload, :count).by(1)
    download = PageDownload.first
    download.downloaded_at.should be_present

    download.storage_uri.should be_present

    download.event_source.name.should eq 'mercury'
    download.event_source.url.should eq 'http://foo.com/bar.html'
  end

  it 'stores to PageStorage' do
    PageStorage.should_receive(:store) do |page_download|
      page_download.downloaded_at.should be_nil
      t = Time.now.utc
      expected_storage_uri = "page_downloads/#{t.strftime('%Y/%m/%d/%H')}/mercury.html"
      page_download.storage_uri.should eq expected_storage_uri
    end

    collector.stub(http_fetch: response, send_mail: true, urls: [url_def])

    collector.collect
  end
end
