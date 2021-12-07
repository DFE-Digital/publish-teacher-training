FactoryBot.define do
  factory :organisation do
    name { "LONDON SCITT" + rand(1000000).to_s }
    sequence(:org_id)

    trait :with_anonymised_data do
      org_id { (Organisation.pluck(:org_id).map(&:to_i).max || 0) + 1 }
    end

    trait :with_user do
      users { [create(:user)] }
    end

    trait :with_providers do
      providers { create_list(:provider, 3) }
    end
  end
end
