# frozen_string_literal: true

module PageObjects
  module Find
    class AgeGroups < PageObjects::Base
      set_url "/find/age-groups"

      element :heading, "h1"

      element :primary, "#find-age-groups-form-age-group-primary-field"
      element :secondary, "#find-age-groups-form-age-group-secondary-field"
      element :further_education, "#find-age-groups-form-age-group-further-education-field"
      element :continue, ".govuk-button"
    end
  end
end
