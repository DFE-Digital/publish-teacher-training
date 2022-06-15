# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class CoursesIndex < PageObjects::Base
        set_url "/support/providers/{provider_id}/courses"

        sections :courses_row, Sections::Course, ".course-row"
      end
    end
  end
end
