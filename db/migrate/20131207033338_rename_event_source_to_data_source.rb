class RenameEventSourceToDataSource < ActiveRecord::Migration
  def change
    rename_table :event_sources, :data_sources
  end
end
