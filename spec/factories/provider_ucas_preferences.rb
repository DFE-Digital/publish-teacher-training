# == Schema Information
#
# Table name: provider_ucas_preference
#
#  id                        :bigint(8)        not null, primary key
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
    type_of_gt12 do
      [
        :coming_or_not,
        :coming_enrol,
        :not_coming,
        :no_response,
      ].sample
    end
  end
end
