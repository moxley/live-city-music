class City < ActiveRecord::Base
  validates :name,
            :slug,
            :state,
            :country,
            presence: true

  def name=(str)
    super
    self.slug = str.parameterize
  end
end
