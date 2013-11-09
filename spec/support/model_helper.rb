module ModelHelper
  def tagger
    @tagger ||= User.create email: 'tagger@a.com'
  end

  def venue(name = 'v1')
    @venue ||= Venue.create name: name
  end
end