require 'storage_helper'

class PageStorage
  attr_accessor :page_download

  def self.store(page_download)
    PageStorage.new(page_download).store
  end

  def self.fetch(page_download)
    PageStorage.new(page_download).fetch
  end

  def initialize(page_download)
    @page_download = page_download
  end

  def directory_name
    'mox-bands01'
  end

  def store
    StorageHelper.store(directory_name,
                        page_download.storage_uri,
                        page_download.content)
  end

  def fetch
    StorageHelper.fetch(directory_name, page_download.storage_uri)
  end
end
