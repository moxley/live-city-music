class City < ActiveRecord::Base
  validates :name,
            :slug,
            :state,
            :country,
            presence: true

  def name=(str)
    super
    generate_slug
  end

  def state=(str)
    super
    generate_slug
  end

  def country=(str)
    super
    generate_slug
  end

  private

  def generate_slug
    self.slug = [name, state, country].join(' ').parameterize
  end
end
