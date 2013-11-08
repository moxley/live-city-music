class AddTypeToGenrePoints < ActiveRecord::Migration
  def change
    change_table :genre_points, bulk: true do |t|
      # type: (tag, peer, name, vendor)
      t.column :type, :string, limit: 20, null: false
      t.column :source_type, :string, limit: 20, null: false
      t.column :source_id, :integer, null: false
    end
  end
end
