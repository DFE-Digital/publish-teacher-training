FactoryBot.define do
  factory :site do
    sequence(:code, &:to_s)
    location_name { 'Main Site' + rand(1000000).to_s }
    association(:provider)
  end
end
