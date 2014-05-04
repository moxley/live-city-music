class City < ActiveRecord::Base
  validates :name,
            :slug,
            :state,
            :country,
            presence: true

  def self.find_by_name(name)
    where(slug: name.parameterize).first
  end

  def name=(str)
    super
    self.slug = str.parameterize
  end
end
