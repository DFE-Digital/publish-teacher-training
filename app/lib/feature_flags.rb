# frozen_string_literal: true

class FeatureFlags
  def self.all
    [
      [:maintenance_mode, 'Puts Find into maintenance mode', 'Find and Publish team'],
      [:maintenance_banner, 'Displays the maintenance mode banner', 'Find and Publish team'],
      [:bursaries_and_scholarships_announced, 'Display scholarship and bursary information', 'Find and Publish team'],
      [:hide_international_relocation_payments, 'Hides international relocation payment information when active', 'Lori Bailey']
    ]
  end
end
