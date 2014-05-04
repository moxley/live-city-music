FactoryGirl.define do
  factory :event do
    title 'Event1'
    venue
    description 'Test event description'
    time_info '2013-10-01 Tue., Oct. 1, 7 p.m.'
    price_info 'free'
    starts_at { Time.now }
  end
end
