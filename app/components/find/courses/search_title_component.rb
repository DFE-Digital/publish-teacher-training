# frozen_string_literal: true

module Find
  module Courses
    class SearchTitleComponent < ViewComponent::Base
      def initialize(subjects:, location_name:, radius:, search_attributes:)
        super()
        @subjects = Array(subjects).compact
        @subjects << "Further education" if @subjects.any? && further_education?(search_attributes) && @subjects.exclude?("Further education")
        @location_name = location_name
        @radius = radius
        @attrs = search_attributes || {}
      end

      def call
        content_tag(:span, title_text)
      end

      def title_text
        return visa_title if no_subject_or_location? && visa_sponsorship?
        return apprenticeship_title if no_subject_or_location_or_visa? && apprenticeship_only?
        return salary_title if no_subject_or_location_or_visa? && salary_only?
        return further_education_title if no_subject_or_location_or_visa? && further_education?
        return fallback_title if @subjects.empty? && no_location?

        named = @subjects.count.between?(1, 2)
        @subjects = @subjects.map { |subject| SubjectHelper.subject_name_in_sentence(subject) }

        if location? && named
          I18n.t("find.courses.search_title.subjects_with_location",
                 subject: @subjects.to_sentence, radius: @radius, location: @location_name)
        elsif location? && !named
          I18n.t("find.courses.search_title.no_subjects_with_location",
                 subject: @subjects.to_sentence, radius: @radius, location: @location_name).upcase_first

        elsif named
          I18n.t("find.courses.search_title.subjects_no_location", subject: @subjects.to_sentence)
        else
          I18n.t("find.courses.search_title.many_subjects_no_location", count: @subjects.count)
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

      def further_education?(attrs = @attrs)
        (attrs || {})["level"] == "further_education"
      end

      def visa_title
        I18n.t("find.courses.search_title.visa_sponsorship").downcase
      end

      def apprenticeship_title
        I18n.t("find.courses.search_title.apprenticeship")
      end

      def salary_title
        I18n.t("find.courses.search_title.salary")
      end

      def further_education_title
        I18n.t("find.courses.search_title.further_education")
      end

      def fallback_title
        filter_count = active_filter_count
        if filter_count.positive?
          I18n.t("find.courses.search_title.fallback_with_filters", count: filter_count)
        else
          I18n.t("find.courses.search_title.fallback")
        end
      end

      # Search attributes that represent candidate-selected filters. Only these
      # contribute to the active filter count shown in the fallback title. Any
      # other key — e.g. return_to, the provider_code/provider_name keys of a
      # provider search, or the location/subject keys handled elsewhere in the
      # title — is ignored automatically by not appearing in this whitelist.
      FILTER_KEYS = %w[
        applications_open
        can_sponsor_visa
        engineers_teach_physics
        funding
        interview_location
        level
        minimum_degree_required
        order
        qualifications
        send_courses
        start_date
        study_types
      ].freeze

      def active_filter_count
        defaults = Find::SearchParamDefaults.new(@attrs)
        @attrs.slice(*FILTER_KEYS).count { |k, v| v.present? && defaults.non_default?(k, v) }
      end
    end
  end
end
