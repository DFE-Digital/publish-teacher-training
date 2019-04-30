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

class ProviderUCASPreference < ApplicationRecord
  belongs_to :provider

  enum type_of_gt12: {
         coming_or_not: 'Coming or Not',
         coming_enrol: 'Coming / Enrol',
         not_coming: 'Not coming',
         no_response: 'No response',
       },
       _prefix: 'type_of_gt12'

  enum send_application_alerts: {
         all: 'Yes, required',
         none: 'No, not required',
         my_programmes: 'Yes - only my programmes',
         accredited_programmes: 'Yes - for accredited programmes only',
       },
       _prefix: 'send_application_alerts_for'
end
