class StorageHelper
  def self.store(directory_name, key, body)
    new.store(directory_name, key, body)
  end

  def self.fetch(directory_name, key)
    new.fetch(directory_name, key)
  end

  def self.connection
    new.connection
  end

  def store(directory_name, key, body, opts = {})
    directory = require_directory(directory_name)
    file = directory.files.create(
      :key    => key,
      :body   => body,
      :public => opts[:public] ? true : false
    )
  end

  def fetch(directory_name, key)
    directory = require_directory(directory_name)
    file = directory.files.get(key) or raise "File not found: #{directory_name}/#{key}"
    file.body
  end

  def require_directory(directory_name)
    find_directory(directory_name) or raise "Directory not found: #{directory_name}"
  end

  def find_directory(directory_name)
    connection.directories.detect { |d| d.key == directory_name }
  end

  def connection
    @connection ||= Fog::Storage.new(provider: 'AWS', aws_access_key_id: access[:key_id], aws_secret_access_key: access[:secret])
  end

  def access
    {key_id: ENV['AWS_ACCESS_KEY'], secret: ENV['AWS_SECRET_KEY']}
  end
end
