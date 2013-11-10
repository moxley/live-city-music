require 'spec_helper'

describe PageCollector do
  it 'fetches web pages and delivers them via email' do
    response = OpenStruct.new(body: '<html>foo</html>')
    collector = PageCollector.new
    collector.should_receive(:http_fetch).at_least(:once) { response }
    date = Time.now.strftime('%Y-%m-%d')
    collector.should_receive(:send_mail) do |mail|
      mail.to.should eq ['moxley.stratton@gmail.com']
      mail.attachments.map(&:filename).should include "mercury-#{date}.html"
    end
    collector.collect
  end

  it 'creates PageDownloads for every downloaded page' do
    response = OpenStruct.new(body: '<html>foo</html>')
    collector = PageCollector.new
    url_def = {name: :mercury, url: 'http://foo.com/bar.html'}
    collector.stub(http_fetch: response, send_mail: true, urls: [url_def])
    date = Time.now.strftime('%Y-%m-%d')

    expect {
      collector.collect
    }.to change(PageDownload, :count).by(1)
    download = PageDownload.first
    download.downloaded_at.should be_present

    # TODO
    #download.storage_uri.should be_present

    download.event_source.name.should eq 'mercury'
    download.event_source.url.should eq 'http://foo.com/bar.html'
  end

  it 'stores to S3'
end
