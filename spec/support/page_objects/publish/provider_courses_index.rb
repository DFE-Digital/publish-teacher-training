# frozen_string_literal: true

require_relative "../sections/course"

module PageObjects
  module Publish
    class ProviderCoursesIndex < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses"

      sections :courses, ".app-table--courses__section" do
        element :subheading, "h2"
        element :name, ".app-table--courses__course-name"
        element :link, ".app-table--courses__course-name a"
        element :course_information, ".app-table--courses__course-information"
        element :status, ".app-table--courses__status"
      end

      element :success_summary, ".govuk-notification-banner--success"

      element :add_course, ".govuk-button", text: "Add course"

      element :scheduled_tag, ".govuk-tag--blue", text: "Scheduled"

      elements :course_counts, ".app-table--courses__count"

      element :empty_message, ".app-table--courses__empty"

      element :filter_heading, "h2", text: "Filter courses"

      element :apply_filters, "button[type='submit']", text: "Apply filters"

      sections :filter_groups, "details.app-c-filter-section" do
        element :heading, ".app-c-filter-section__summary-heading"
        element :selected_count, ".app-c-filter-section__count"

        # The options this group offers, in order. A collapsed group hides its
        # labels, so ask for the hidden text too.
        def option_labels
          all("label", visible: :all).map { |label| label.text(:all).strip }
        end
      end

      section :active_filters, ".app-active-filters" do
        elements :chips, ".app-active-filters__remove-filter"
        element :clear_all, ".app-c-filter-summary__clear-filters"
      end

      # The filter group headings currently shown, in order.
      def filter_group_headings
        filter_groups.map { |group| group.heading.text.strip }
      end
    end
  end
end
