# frozen_string_literal: true

module PageObjects
  module Find
    class CoursesByLocationOrTrainingProvider < PageObjects::Base
      set_url "/find"

      element :heading, "h1"

      element :by_city_town_or_postcode_radio, "#l_1"
      element :location, "#location"
      element :across_england, "#l_2"
      element :by_school_uni_or_provider, "#l_3"
      element :provider_options, "#query-field"
      element :continue, ".govuk-button"
    end
  end
end
