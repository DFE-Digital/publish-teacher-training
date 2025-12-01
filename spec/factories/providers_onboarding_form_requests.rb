FactoryBot.define do
  factory :providers_onboarding_form_request do
    status { "pending" }
    form_name { "MyText" }
    support_agent_id { nil }
    zendesk_link { "MyString" }
    uuid { SecureRandom.uuid }
    provider_metadata { {} }
    email_address { "MyText" }
    first_name { "MyText" }
    last_name { "MyText" }
    organisation_name { "MyString" }
    address_line_1 { "MyText" }
    address_line_2 { "MyText" }
    address_line_3 { "MyText" }
    town_or_city { "MyText" }
    county { "MyText" }
    postcode { "MyText" }
    phone_number { "MyText" }
    contact_email_address { "MyText" }
    organisation_website { "MyText" }
    ukprn { "MyString" }
    accredited_provider { false }
    urn { "MyString" }
  end
end
