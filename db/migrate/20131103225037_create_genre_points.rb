class CreateGenrePoints < ActiveRecord::Migration
  def change
    create_table :genre_points do |t|
      t.string  :target_type, limit: 30, null: false
      t.integer :target_id, null: false
      t.integer :genre_id, null: false
      t.float   :value, null: false, default: 0.0

      t.timestamps
    end
  end
end
