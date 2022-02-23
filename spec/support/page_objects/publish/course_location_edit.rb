# frozen_string_literal: true

require_relative "../sections/vacancy"

module PageObjects
  module Publish
    class CourseLocationEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/locations"

      sections :vacancies, Sections::Vacancy, ".govuk-checkboxes__item"

      element :submit, 'button.govuk-button[type="submit"]'

      def vacancy_names
        vacancies.map { |el| el.find(".govuk-label").text }
      end

      def vacancy_checked_values
        vacancies.map(&:checked?)
      end
    end
  end
end
