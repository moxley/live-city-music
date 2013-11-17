class ImportGenres < ActiveRecord::Migration
  def up
    change_column :genres, :name, :string, limit: 40, null: false
    add_index :genres, :name, unique: true

    return if Rails.env == 'test'

    execute "TRUNCATE genre_points RESTART IDENTITY"
    Dir.glob('db/list_of_styles*.html').each do |path|
      Genre.import_from_file(File.new(path))
    end
  end

  def down
    execute "TRUNCATE genres RESTART IDENTITY"
    change_column :genres, :name, :string, limit: 30, null: false
    remove_index :genres, :name
  end
end
