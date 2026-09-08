# frozen_string_literal: true

class FeatureFlags
  def self.all
    [
      [:maintenance_mode, "Puts Find into maintenance mode", "Find and Publish team"],
      [:maintenance_banner, "Displays the maintenance mode banner", "Find and Publish team"],
      [:publish_rollover_banner, "Displays the rollover banner in Publish", "Find and Publish team"],
      [:bursaries_and_scholarships_announced, "Display scholarship and bursary information", "Find and Publish team"],
      [:candidate_accounts, "Enable candidate accounts feature", "Find and Publish team"],
      [:require_authentication_for_find_results, "[EMERGENCY MODE] Require candidates to sign in before viewing Find search results. Enable only during abusive traffic or exceptional load; disable after the incident.", "Find and Publish team"],
      [:email_alerts, "Enable email alerts for candidates", "Find and Publish team"],
      [:course_sites_updated_email_notification, "Send email notifications when a course's associated schools are updated", "Find and Publish team"],
      [:wizard_add_course_flow, "Enables the wizard add course flow that uses the DfE wizard", "Find and Publish team"],
      [:course_publishing_uses_new_school_model, "Use the new school model for Find school location queries", "Find and Publish team"],
    ]
  end
end
