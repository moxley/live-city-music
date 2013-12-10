class AddMissingGenres < ActiveRecord::Migration
  def up
    change_table :genres, bulk: true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    return if Rails.env.test?
    execute "INSERT INTO genres (name, created_at, updated_at) VALUES ('Latin', NOW(), NOW())"
  end

  def down
    execute "DELETE FROM genres WHERE lower(name) = 'latin'"
    drop_column :genres, :created_at
    drop_column :genres, :update_at
  end
end
