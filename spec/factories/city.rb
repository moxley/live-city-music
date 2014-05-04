FactoryGirl.define do
  factory :city do
    name 'Vancouver'
    state 'WA'
    country 'US'

    factory :portland do
      name 'Portland'
      state 'OR'
      country 'US'
    end

    factory :seattle do
      name 'Seattle'
      state 'WA'
      country 'US'
    end
  end
end
