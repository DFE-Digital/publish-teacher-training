# frozen_string_literal: true

module PageObjects
  module Find
    class SecondarySubjects < PageObjects::Base
      set_url '/subjects?age_group=secondary'

      element :music, '#find-subjects-form-subject-codes-w3-field'
      element :continue, 'form .govuk-button'
    end
  end
end
