class FeatureFlags
  def self.all
    [
      [:maintenance_mode, "Puts Find into maintenance mode", "Find and Publish team"],
      [:maintenance_banner, "Displays the maintenance mode banner", "Find and Publish team"],
      [:cache_courses, "Caches request to the Teacher Training API for individual courses", "Find and Publish team"],
      [:send_web_requests_to_big_query, "Send events to Google Big Query", "Find and Publish team"],
      [:bursaries_and_scholarships_announced, "Display scholarship and bursary information", "Find and Publish team"],
    ]
  end
end
