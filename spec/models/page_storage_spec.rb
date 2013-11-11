require 'spec_helper'

describe PageStorage do
  it 'stores a page download' do
    content = "<html><body>foo</body></html>"
    key = "page_downloads/mercury-2013-10-01.html"
    page_download = PageDownload.new content: content, storage_uri: key

    StorageHelper.should_receive(:store).with('mox-bands01', key, content)

    PageStorage.store(page_download)
  end
end
