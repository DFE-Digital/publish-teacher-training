# frozen_string_literal: true

require_relative "../sections/errorlink"
require_relative "../sections/vacancy"

module PageObjects
  module Publish
    class CourseVacanciesEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/vacancies"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :confirm_no_vacancies, "#publish-course-vacancies-form-change-vacancies-confirmation-no-vacancies-confirmation-field"
      element :confirm_has_vacancies, "#publish-course-vacancies-form-change-vacancies-confirmation-has-vacancies-confirmation-field"

      element :confirm_no_vacancies_for_sites, "#publish-course-vacancies-form-has-vacancies-field"

      element :vacancies_radio_choice, ".govuk-radios"
      element :vacancies_radio_no_vacancies, "#publish-course-vacancies-form-has-vacancies-field"
      element :vacancies_radio_has_some_vacancies, "#publish-course-vacancies-form-has-vacancies-true-field"

      sections :vacancies, Sections::Vacancy, ".govuk-checkboxes__item"

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end

      def vacancy_names
        vacancies.map(&:text)
      end

      def vacancy_checked_values
        vacancies.map(&:checked?)
      end
    end
  end
end
