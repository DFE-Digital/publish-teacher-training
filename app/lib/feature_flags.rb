# frozen_string_literal: true

class FeatureFlags
  def self.all
    [
      [:maintenance_mode, "Puts Find into maintenance mode", "Find and Publish team"],
      [:maintenance_banner, "Displays the maintenance mode banner", "Find and Publish team"],
      [:bursaries_and_scholarships_announced, "Display scholarship and bursary information", "Find and Publish team"],
      [:hide_applications_open_date, "Hides the the option to create, edit and view a courses open date"],
    ]
  end
end
