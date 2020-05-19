FactoryBot.define do
  factory :provider_ucas_preference, aliases: [:ucas_preferences] do
    provider

    application_alert_email { Faker::Internet.email }
    gt12_response_destination { Faker::Internet.email }

    type_of_gt12 do
      %i[
        coming_or_not
        coming_enrol
        not_coming
        no_response
      ].sample
    end

    send_application_alerts do
      %i[
        all
        none
        my_programmes
        accredited_programmes
      ].sample
    end
  end
end
