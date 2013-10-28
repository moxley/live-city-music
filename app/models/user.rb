class User < ActiveRecord::Base
  validates_uniqueness_of :email, case_sensitive: false
  acts_as_tagger

  def email=(str)
    super str ? str.downcase : nil
  end
end
