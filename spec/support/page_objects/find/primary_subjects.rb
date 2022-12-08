# frozen_string_literal: true

module PageObjects
  module Find
    class PrimarySubjects < PageObjects::Base
      set_url "find/subjects?age_group=primary"

      element :primary, "#find-subjects-form-subjects-00-field"
      element :primary_with_english, "#find-subjects-form-subject-codes-01-field"
      element :find_courses, ".govuk-button", text: "Find courses"
    end
  end
end
