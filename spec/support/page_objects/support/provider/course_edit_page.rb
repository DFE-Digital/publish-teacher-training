# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class CourseEdit < PageObjects::Base
        set_url "/support/providers/{provider_id}/courses/{course_id}/edit"

        element :course_code, "#course-course-code-field"
        element :error_summary, ".govuk-error-summary"
        element :continue, ".govuk-button"
      end
    end
  end
end
