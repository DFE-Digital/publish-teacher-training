FactoryBot.define do
  factory :nctl_organisation do
    nctl_id { rand(1000000).to_s }
  end
end
