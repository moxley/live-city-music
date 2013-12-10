class AddReverbDataSource < ActiveRecord::Migration
  def up
    return if Rails.env.test?
    execute "INSERT INTO data_sources (name, url, created_at, updated_at) VALUES ('reverb', 'http://www.reverbnation.com/', NOW(), NOW())"
  end

  def down
    execute "DELETE FROM data_sources WHERE name='reverb'"
  end
end
