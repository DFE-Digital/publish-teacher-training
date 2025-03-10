# frozen_string_literal: true

class FeatureFlags
  def self.all
    [
      [:maintenance_mode, 'Puts Find into maintenance mode', 'Find and Publish team'],
      [:maintenance_banner, 'Displays the maintenance mode banner', 'Find and Publish team'],
      [:bursaries_and_scholarships_announced, 'Display scholarship and bursary information', 'Find and Publish team'],
      [:prefiltering_find_redesign, 'Prefiltering Find redesign', 'Find and Publish team']
    ]
  end
end
