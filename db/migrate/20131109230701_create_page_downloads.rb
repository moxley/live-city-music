class CreatePageDownloads < ActiveRecord::Migration
  def change
    create_table :page_downloads do |t|
      t.datetime :downloaded_at, null: false
      t.integer :event_source_id, null: false
      t.string :storage_uri
      t.datetime :processed_at, null: true

      t.timestamps
    end
  end
end
