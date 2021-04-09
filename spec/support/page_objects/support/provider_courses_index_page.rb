# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderCoursesIndex < PageObjects::Base
      set_url "/support/providers/{provider_id}/courses"

      def courses
        page.find_all(".course-row")
      end
    end
  end
end
