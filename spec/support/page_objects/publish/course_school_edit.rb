# frozen_string_literal: true

require_relative "../sections/vacancy"

module PageObjects
  module Publish
    class CourseSchoolEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/schools"

      SCHOOL_CHECKBOX = "input[name='publish_course_school_form[school_uuids][]']"

      sections :vacancies, Sections::Vacancy, ".govuk-checkboxes__item"

      element :submit, 'button.govuk-button[type="submit"]'
      # Two controls say "Show all schools" - the one under a collapsed list and
      # the one in the no results message - but they are never on screen at the
      # same time, so this finds whichever one the provider can actually see.
      element :show_all_schools, ".app-button-link", text: "Show all schools"
      element :search_panel, ".app-school-search"
      element :changes_summary, "[data-schools-changes-target='summary']"
      # Scoped by its target rather than role=status: the page carries several live
      # regions, and this spec is only ever interested in the summary's.
      element :announcement, "[data-schools-changes-target='status']", visible: :all
      element :added, "[data-schools-changes-target='added']"
      element :removed, "[data-schools-changes-target='removed']"

      def vacancy_names
        vacancies.map { |el| el.find(".govuk-label").text }.reject { |name| name == "Select all schools" }
      end

      def vacancy_checked_values
        vacancies.map(&:checked?)
      end

      def visible_school_names
        all(".govuk-checkboxes__item", visible: true).filter_map do |item|
          item.find(".govuk-label").text if item.has_css?(SCHOOL_CHECKBOX, visible: :all)
        end
      end

      def school_checkboxes
        all("[data-schools-changes-target='school']", visible: :all)
      end

      def added_school_names
        added.all("li").map(&:text)
      end

      def removed_school_names
        removed.all("li").map(&:text)
      end

      def visible_school_checkbox_count
        # Count the visible checkbox rows that hold a school checkbox. We inspect
        # the wrapper's visibility (a block element) rather than the input, since
        # GOV.UK visually hides the real <input> element itself.
        all(".govuk-checkboxes__item", visible: true).count do |item|
          item.has_css?(SCHOOL_CHECKBOX, visible: :all)
        end
      end
    end
  end
end
