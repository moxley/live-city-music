class ReImportGenres < ActiveRecord::Migration
  def up
    return if Rails.env == 'test'
    execute "TRUNCATE genre_points RESTART IDENTITY"
    execute "TRUNCATE genres RESTART IDENTITY"
    Dir.glob('db/list_of_styles*.html').sort.each do |path|
      Genre.import_from_file(File.new(path))
    end
  end

  def down
  end
end
