FactoryBot.define do
  factory :providers_onboarding_form_request do
    status { "pending" }
    form_name { "Onboarding Form" }
    support_agent_id { nil }
    zendesk_link { "https://zendesk.example.com/ticket/123" }
    uuid { SecureRandom.uuid }
    provider_metadata { {} }
    email_address { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    provider_name { Faker::Company.name }
    address_line_1 { Faker::Address.street_address }
    address_line_2 { Faker::Address.secondary_address }
    address_line_3 { nil }
    town_or_city { Faker::Address.city }
    county { Faker::Address.state }
    postcode { Faker::Address.postcode }
    telephone { Faker::PhoneNumber.phone_number }
    contact_email_address { Faker::Internet.email }
    website { Faker::Internet.url }
    ukprn { Faker::Number.within(range: 10_000_000..19_999_999).to_s }
    accredited_provider { [true, false].sample }
    urn { Faker::Number.number(digits: 6).to_s }
  end
end
