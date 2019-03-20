# == Schema Information
#
# Table name: provider_ucas_preference
#
#  id                      :bigint(8)        not null, primary key
#  provider_id             :integer          not null
#  type_of_gt12            :text
#  send_application_alerts :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class ProviderUCASPreference < ApplicationRecord
  belongs_to :provider

  enum type_of_gt12: {
         coming_or_not: 'Coming or Not (GT12B)',
         coming_enrol: 'Coming / Enrol (GT12E)',
         not_coming: 'Not coming (GT12N)',
         no_response: 'No response (GT12)',
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
