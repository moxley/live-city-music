class CreateEventSources < ActiveRecord::Migration
  def change
    create_table :event_sources do |t|
      t.string :name, limit: 30, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
