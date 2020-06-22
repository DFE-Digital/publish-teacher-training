FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    first_login_date_utc { Faker::Time.backward(days: 1).utc }
    welcome_email_date_utc { Faker::Time.backward(days: 1).utc }
    accept_terms_date_utc { Faker::Time.backward(days: 1).utc }
    sign_in_user_id { SecureRandom.uuid }
    state { "rolled_over" }

    trait :admin do
      admin { true }
      email { "factory.admin@education.gov.uk" }
    end

    trait :with_organisation do
      organisations { [create(:organisation)] }
    end

    trait :with_provider do
      organisations { [create(:organisation, providers: [create(:provider)])] }
    end

    trait :inactive do
      accept_terms_date_utc { nil }
    end

    trait :with_magic_link_token do
      magic_link_token { SecureRandom.uuid }
      magic_link_token_sent_at { Time.now.utc }
    end

    trait :discarded do
      discarded_at { Time.now.utc }
    end
  end
end
