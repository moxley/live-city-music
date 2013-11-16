class MarkPageDownloadsAsImported < ActiveRecord::Migration
  def up
    execute "UPDATE page_downloads SET imported_at = '2013-10-28 04:40:56' WHERE downloaded_at < '2013-10-28'"
  end

  def down
    execute "UPDATE page_downloads SET imported_at = NULL WHERE downloaded_at < '2013-10-28'"
  end
end
