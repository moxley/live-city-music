require 'spec_helper'

describe PageCollector do
  let(:response) { OpenStruct.new(body: '<html>foo</html>') }
  let(:collector) { PageCollector.new }
  let(:data_source) { DataSource.create name: 'mercury', url: 'http://foo.com/bar.html' }
  let(:stubbed_collector) do
    collector.stub(http_fetch: response, send_mail: true, data_sources: [data_source])
    collector
  end

  def stub_importer
    job = double(:job)
    job.stub(:import_page_download)
    PageImport::MercuryImporter.stub(delay: job)
  end

  it 'fetches web pages' do
    collector.stub(data_sources: [data_source])
    collector.should_receive(:http_fetch).at_least(:once) { response }
    date = Time.now.utc.strftime('%Y-%m-%dT%H')

    PageStorage.stub(store: true)
    stub_importer

    collector.collect
  end

  it 'creates PageDownloads for every downloaded page' do
    collector.stub(http_fetch: response, send_mail: true, data_sources: [data_source])
    PageStorage.stub(store: true)
    stub_importer

    expect {
      collector.collect
    }.to change(PageDownload, :count).by(1)
    download = PageDownload.first
    download.downloaded_at.should be_present

    download.storage_uri.should be_present

    download.data_source.should eq data_source
  end

  it 'stores to PageStorage' do
    PageStorage.should_receive(:store) do |page_download|
      page_download.downloaded_at.should be_nil
      page_download.storage_uri.should eq page_download.calculate_storage_uri
    end

    stub_importer

    stubbed_collector.collect
  end

  it 'fires off jobs to import each downloaded page' do
    job = double(:job)
    job.should_receive(:import_page_download) do |id|
      id.should be_kind_of(Fixnum)
    end
    PageImport::MercuryImporter.stub(delay: job)

    PageStorage.stub(store: true)

    stubbed_collector.collect
  end
end
