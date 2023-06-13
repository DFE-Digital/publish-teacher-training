# frozen_string_literal: true

require_relative '../sections/edit_school'

module PageObjects
  module Publish
    class CourseSchoolEdit < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/schools'

      sections :schools, Sections::EditSchool, '.govuk-checkboxes__item'

      element :submit, 'button.govuk-button[type="submit"]'

      def school_names
        schools.map { |el| el.find('.govuk-label').text }
      end
    end
  end
end
