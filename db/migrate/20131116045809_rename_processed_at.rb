class RenameProcessedAt < ActiveRecord::Migration
  def change
    rename_column :page_downloads, :processed_at, :imported_at
  end
end
