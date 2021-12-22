# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class CourseEdit < PageObjects::Base
        set_url "/support/providers/{provider_id}/courses/{course_id}/edit"

        element :course_code, "#support-edit-course-form-course-code-field"
        element :name, "#support-edit-course-form-name-field"
        element :start_date_day, "#support_edit_course_form_start_date_3i"
        element :start_date_month, "#support_edit_course_form_start_date_2i"
        element :start_date_year, "#support_edit_course_form_start_date_1i"
        element :error_summary, ".govuk-error-summary"
        element :continue, ".govuk-button"
      end
    end
  end
end
