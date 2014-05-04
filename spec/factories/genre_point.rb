FactoryGirl.define do
  factory :genre_point do
    genre
    target { build(:artist) }
    value 1.0
    point_type 'self_tag'
    source { build(:data_source) }
  end
end
