# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class CourseConfirmation < PageObjects::Base
      class SummaryList < SitePrism::Section
        element :value, ".govuk-summary-list__value"
        element :change_link, ".govuk-summary-list__actions .govuk-link"
      end

      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/confirmation{?query*}"

      section :details, "[data-qa=course__details]" do
        section :level, SummaryList, "[data-qa=course__level]"
        section :is_send, SummaryList, "[data-qa=course__is_send]"
        section :subjects, SummaryList, "[data-qa=course__subjects]"
        section :age_range, SummaryList, "[data-qa=course__age_range]"
        section :outcome, SummaryList, "[data-qa=course__outcome]"
        section :apprenticeship, SummaryList, "[data-qa=course__apprenticeship]"
        section :fee_or_salary, SummaryList, "[data-qa=course__fee_or_salary]"
        section :study_mode, SummaryList, "[data-qa=course__study_mode]"
        section :locations, SummaryList, "[data-qa=course__locations]"
        element :single_location_help_text, "[data-qa=course__locations__help]"
        section :accredited_body, SummaryList, "[data-qa=course__accredited_body]"
        section :applications_open, SummaryList, "[data-qa=course__applications_open]"
        section :start_date, SummaryList, "[data-qa=course__start_date]"
        section :name, SummaryList, "[data-qa=course__name]"
        section :description, SummaryList, "[data-qa=course__description]"
        section :entry_requirements, SummaryList, "[data-qa=course__entry_requirements]"
      end

      section :preview, "[data-qa=course__preview]" do
        element :name, "[data-qa=course__name]"
        element :description, "[data-qa=course__description]"
      end

      element :save_button, "[data-qa=course__save]"
    end
  end
end
