class RenameEventSourceIdToDataSourceId < ActiveRecord::Migration
  def change
    rename_column :page_downloads, :event_source_id, :data_source_id
  end
end
