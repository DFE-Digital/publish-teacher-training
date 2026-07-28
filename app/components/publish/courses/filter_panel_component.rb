# frozen_string_literal: true

module Publish
  module Courses
    # The filter sidebar on the publish course list: the active filter chips,
    # then one collapsible section of checkboxes per filter group.
    #
    # Which groups are shown is a caller's decision, so that a provider whose
    # courses do not vary on an attribute can be shown a shorter panel without
    # this component knowing anything about their courses.
    class FilterPanelComponent < ApplicationComponent
      def initialize(filter_form:, provider:, visible_groups: ::Publish::CourseFilterForm::GROUPS, classes: [], html_attributes: {})
        super(classes:, html_attributes:)
        @filter_form = filter_form
        @provider = provider
        @visible_groups = visible_groups
      end

      attr_reader :filter_form, :provider, :visible_groups

      def courses_path(params = {})
        helpers.publish_provider_recruitment_cycle_courses_path(
          provider.provider_code, provider.recruitment_cycle_year, params
        )
      end

      def selected_count(group)
        filter_form.filter_counts[group]
      end

      def active_filters_component
        # clear_all_text is left to the shared component's "Clear all" default.
        ::Courses::ActiveFiltersComponent.new(
          active_filters: filter_form.active_filters,
          search_params: filter_form.filter_params,
          path_builder: ->(params) { courses_path(params) },
          clear_all_path: courses_path,
        )
      end
    end
  end
end
