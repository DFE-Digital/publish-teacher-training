# frozen_string_literal: true

module PageObjects
  module Find
    class PrimarySubjects < PageObjects::Base
      set_url "find/subjects?age_group=primary"

      element :primary_with_english, "#find-subjects-form-subject-codes-01-field"
      element :continue, ".govuk-button"
    end
  end
end
