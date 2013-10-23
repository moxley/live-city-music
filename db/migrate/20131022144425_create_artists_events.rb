class CreateArtistsEvents < ActiveRecord::Migration
  def change
    create_table :artists_events do |t|
      t.references :artist, index: true
      t.references :event, index: true

      t.timestamps
    end
  end
end
