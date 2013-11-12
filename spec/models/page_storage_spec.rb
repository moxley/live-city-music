require 'spec_helper'

describe PageStorage do
  include ModelHelper

  it 'stores a page download' do
    key = "page_downloads/mercury-2013-10-01.html"
    page_download = PageDownload.new content: page_content, storage_uri: key

    StorageHelper.should_receive(:store).with('mox-bands01', key, page_content)

    PageStorage.store(page_download)
  end
end
