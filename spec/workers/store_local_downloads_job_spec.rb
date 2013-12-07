require 'spec_helper'

describe StoreLocalDownloadsJob do
  include ModelHelper

  subject(:job) { StoreLocalDownloadsJob.new }
  let(:path) { "tmp/imports/mercury-2013-10-01.html" }

  describe '#parse_filename' do
    it 'parses "downloaded_at"' do
      _, downloaded_at = job.parse_filename(path)
    end

    it 'parses source' do
      source, _ = job.parse_filename(path)
      source.should eq 'mercury'
    end
  end

  describe '#store' do
    it 'calls PageStorage.store with PageDownload' do
      data_source = DataSource.create! name: 'mercury', url: 'foo'
      PageStorage.should_receive(:store) do |page_download|
        page_download.downloaded_at.should be_present
        page_download.data_source.should eq data_source
        page_download.storage_uri.should eq "production/page_downloads/2013/10/01/23/mercury.html"
        page_download.content.should eq page_content
        page_download.env.should eq 'production'
      end
      File.stub(read: page_content)
      job.store(path)
    end
  end
end
