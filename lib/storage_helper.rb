class StorageHelper
  def self.store(directory_name, key, body)
    new.store(directory_name, key, body)
  end

  def self.connection
    new.connection
  end

  def store(directory_name, key, body, opts = {})
    directory = connection.directories.detect { |d| d.key == directory_name }
    raise "Directory not found: #{directory_name}" unless directory
    file = directory.files.create(
      :key    => key,
      :body   => body,
      :public => opts[:public] ? true : false
    )
  end

  def connection
    @connection ||= Fog::Storage.new(provider: 'AWS', aws_access_key_id: access[:key_id], aws_secret_access_key: access[:secret])
  end

  def access
    {key_id: ENV['S3_KEY'], secret: ENV['S3_SECRET']}
  end
end
