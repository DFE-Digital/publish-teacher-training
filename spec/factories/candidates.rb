FactoryBot.define do
  factory :candidate do
    email_address { "my.great@emailaddress.com" }

    trait :logged_in do
      authentications { build_list(:authentication, 1) }
      sessions { build_list(:session, 1) }
    end
  end
end
