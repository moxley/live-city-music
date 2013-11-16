class GenreJob
  def self.perform
    new.perform
  end

  def perform
    perform_on_venues
    perform_on_artists
  end

  def perform_on_venues
    perform_on(Venue)
  end

  def perform_on_artists
    perform_on(Artist)
  end

  def perform_on(ar_class)
    ar_class.pluck(:id).each do |id|
      seconds = rand(3600)
      InstanceGenreJob.perform_in(seconds, ar_class.to_s, id)
    end
  end

  class InstanceGenreJob
    include Sidekiq::Worker

    def perform(ar_class_s, id)
      instance = Object.const_get(ar_class_s).find(id)
      instance.calculate_and_apply_genres
    end
  end
end
