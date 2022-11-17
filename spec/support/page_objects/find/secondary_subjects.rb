# frozen_string_literal: true

module PageObjects
  module Find
    class SecondarySubjects < PageObjects::Base
      set_url "find/subjects?age_group=secondary"

      element :music, "#find-subjects-form-subject-codes-w3-field"
      element :continue, ".govuk-button"
    end
  end
end
