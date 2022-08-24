# frozen_string_literal: true

module PageObjects
  module Find
    class CoursesByLocationOrTrainingProvider < PageObjects::Base
      set_url "/find"

      element :heading, "h1"

      element :by_city_town_or_postcode_radio, "#find-courses-by-location-or-training-provider-form-find-courses-by-city-town-postcode-field"
      element :across_england, "#find-courses-by-location-or-training-provider-form-find-courses-across-england-field"
      element :by_school_uni_or_provider, "#find-courses-by-location-or-training-provider-form-find-courses-by-school-uni-or-provider-field"
      element :provider_options, "#find-courses-by-location-or-training-provider-form-school-uni-or-provider-query-field"
      element :continue, ".govuk-button"
    end
  end
end
