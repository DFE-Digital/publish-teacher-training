# frozen_string_literal: true

module PageObjects
  module PublishInterface
    class CourseVacanciesEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/vacancies"

      element :error_summary, ".govuk-error-summary"

      element :confirm_no_vacancies, "#publish-interface-course-vacancies-form-change-vacancies-confirmation-no-vacancies-confirmation-field"
      element :confirm_has_vacancies, "#publish-interface-course-vacancies-form-change-vacancies-confirmation-has-vacancies-confirmation-field"

      element :confirm_no_vacancies_for_sites, "#publish-interface-course-vacancies-form-has-vacancies-field"

      element :vacancies_radio_choice, ".govuk-radios"
      element :vacancies_radio_no_vacancies, "#publish-interface-course-vacancies-form-has-vacancies-field"
      element :vacancies_radio_has_some_vacancies, "#publish-interface-course-vacancies-form-has-vacancies-true-field"

      element :submit, 'button.govuk-button[type="submit"]'

      def errors
        within(error_summary) do
          all(".govuk-error-summary__list li").map(&:text)
        end
      end

      def sites
        within("#publish-interface-course-vacancies-form-has-vacancies-true-conditional") do
          all(".govuk-checkboxes__item")
        end
      end

      def site_checkboxes
        within("#publish-interface-course-vacancies-form-has-vacancies-true-conditional") do
          all(".govuk-checkboxes__input")
        end
      end
    end
  end
end
