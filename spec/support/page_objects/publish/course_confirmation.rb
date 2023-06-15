# frozen_string_literal: true

require_relative '../sections/error_link'

module PageObjects
  module Publish
    class CourseConfirmation < PageObjects::Base
      class SummaryList < SitePrism::Section
        element :value, '.govuk-summary-list__value'
        element :change_link, '.govuk-summary-list__actions .govuk-link'
      end

      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/confirmation{?query*}'

      section :details, '[data-qa=course__details]' do
        section :level, SummaryList, '[data-qa=course__level]'
        section :is_send, SummaryList, '[data-qa=course__is_send]'
        section :subjects, SummaryList, '[data-qa=course__subjects]'
        section :engineers_teach_physics, SummaryList, '[data=qa=course__engineers_teach_physics]'
        section :age_range, SummaryList, '[data-qa=course__age_range]'
        section :outcome, SummaryList, '[data-qa=course__outcome]'
        section :apprenticeship, SummaryList, '[data-qa=course__apprenticeship]'
        section :funding_type, SummaryList, '[data-qa=course__funding_type]'
        section :study_mode, SummaryList, '[data-qa=course__study_mode]'
        section :schools, SummaryList, '[data-qa=course__schools]'
        section :study_sites, SummaryList, '[data-qa=course__study_sites]'
        section :accredited_provider, SummaryList, '[data-qa=course__accredited_provider]'
        section :applications_open, SummaryList, '[data-qa=course__applications_open]'
        section :start_date, SummaryList, '[data-qa=course__start_date]'
        section :name, SummaryList, '[data-qa=course__name]'
        section :entry_requirements, SummaryList, '[data-qa=course__entry_requirements]'
      end

      element :save_button, '[data-qa=course__save]'
    end
  end
end
