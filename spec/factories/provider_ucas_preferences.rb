# == Schema Information
#
# Table name: provider_ucas_preference
#
#  id                        :bigint           not null, primary key
#  provider_id               :integer          not null
#  type_of_gt12              :text
#  send_application_alerts   :text
#  application_alert_email   :text
#  gt12_response_destination :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

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
