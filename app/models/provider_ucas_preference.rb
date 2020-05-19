class ProviderUCASPreference < ApplicationRecord
  belongs_to :provider

  enum type_of_gt12: {
    coming_or_not: "Coming or Not",
         coming_enrol: "Coming / Enrol",
         not_coming: "Not coming",
         no_response: "No response",
  },
       _prefix: "type_of_gt12"

  enum send_application_alerts: {
    all: "Yes, required",
         none: "No, not required",
         my_programmes: "Yes - only my programmes",
         accredited_programmes: "Yes - for accredited programmes only",
  },
       _prefix: "send_application_alerts_for"

  def gt12_contact=(gt12_contact)
    update(gt12_response_destination: gt12_contact)
  end

  def application_alert_contact=(application_alert_contact)
    update(application_alert_email: application_alert_contact)
  end
end
