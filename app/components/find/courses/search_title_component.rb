# frozen_string_literal: true

module Find
  module Courses
    class SearchTitleComponent < ViewComponent::Base
      def initialize(subjects:, location_name:, radius:, search_attributes:)
        super
        @subjects = Array(subjects).compact
        @location_name = location_name
        @radius = radius
        @attrs = search_attributes || {}
      end

      def call
        content_tag(:span, title_text)
      end

    private

      def title_text
        return visa_title if no_subject_or_location? && visa_sponsorship?
        return apprenticeship_title if no_subject_or_location_or_visa? && apprenticeship_only?
        return salary_title if no_subject_or_location_or_visa? && salary_only?

        if @subjects.count == 1 && no_location?
          I18n.t("find.courses.search_title.one_subject_no_location", subject: @subjects.first)
        elsif @subjects.count == 2 && no_location?
          I18n.t("find.courses.search_title.two_subjects_no_location", subject1: @subjects.first, subject2: @subjects.second)
        elsif @subjects.count >= 3 && no_location?
          I18n.t("find.courses.search_title.many_subjects_no_location", count: @subjects.count)
        elsif @subjects.empty? && location?
          I18n.t("find.courses.search_title.no_subjects_with_location", radius: @radius, location: @location_name)
        elsif @subjects.count >= 3 && location?
          I18n.t("find.courses.search_title.no_subjects_with_location", radius: @radius, location: @location_name)
        elsif @subjects.count == 1 && location?
          I18n.t("find.courses.search_title.one_subject_with_location", subject: @subjects.first, radius: @radius, location: @location_name)
        elsif @subjects.count == 2 && location?
          I18n.t("find.courses.search_title.two_subjects_with_location", subject1: @subjects.first, subject2: @subjects.second, radius: @radius, location: @location_name)
        else
          fallback_title
        end
      end

      def no_location?
        !location?
      end

      def location?
        @location_name.present?
      end

      def no_subject_or_location?
        @subjects.empty? && no_location?
      end

      def visa_sponsorship?
        @attrs["can_sponsor_visa"].present?
      end

      def no_subject_or_location_or_visa?
        no_subject_or_location? && !visa_sponsorship?
      end

      def apprenticeship_only?
        funding = Array(@attrs["funding"])
        funding.include?("apprenticeship") && !funding.include?("salary") && !funding.include?("fee")
      end

      def salary_only?
        funding = Array(@attrs["funding"])
        funding.include?("salary") && !funding.include?("fee")
      end

      def visa_title
        I18n.t("find.courses.search_title.visa_sponsorship")
      end

      def apprenticeship_title
        I18n.t("find.courses.search_title.apprenticeship")
      end

      def salary_title
        I18n.t("find.courses.search_title.salary")
      end

      def fallback_title
        filter_count = active_filter_count
        if filter_count.positive?
          I18n.t("find.courses.search_title.fallback_with_filters", count: filter_count)
        else
          I18n.t("find.courses.search_title.fallback")
        end
      end

      DISPLAY_EXCLUDED_KEYS = %w[provider_code provider_name].freeze

      def active_filter_count
        defaults = Find::SearchParamDefaults.new(@attrs)
        @attrs.count { |k, v| v.present? && DISPLAY_EXCLUDED_KEYS.exclude?(k) && defaults.non_default?(k, v) }
      end
    end
  end
end
