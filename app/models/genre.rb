class Genre
  attr_accessor :id, :name
  GENRES = [
    {id: 1, name: 'jazz'}
  ]

  def self.all
    GENRES.map do |h|
      g = Genre.new
      g.id = h[:id]
      g.name = h[:name]
      g
    end
  end

  def self.find_by_name(name)
    all.detect { |g| g.name == name }
  end

  def self.find(id)
    all.detect { |g| g.id == id }
  end
end
