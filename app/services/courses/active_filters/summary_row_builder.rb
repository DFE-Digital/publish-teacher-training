# frozen_string_literal: true

module Courses
  module ActiveFilters
    module SummaryRowBuilder
      FILTER_OPTION_KEYS = {
        qualifications: "qualification_options",
        minimum_degree_required: "minimum_degree_required_options",
        funding: "funding_options",
        study_types: "study_type_options",
        start_date: "start_date_options",
      }.freeze

      def build_summary_rows(attrs, subject_names: [])
        labels = I18n.t("find.candidates.email_alerts.new.summary_labels")

        filters = HashExtractor.new(
          attrs,
          subject_names:,
          provider_name: attrs["provider_name"],
        ).call

        filters.group_by(&:id).filter_map do |id, group|
          label = labels[id]
          next unless label

          values = group.map { |f| resolve_filter_value(id, f) }.compact
          next if values.empty?

          { label:, value: values.join(", ") }
        end
      end

      private

      def resolve_filter_value(id, filter)
        option_key = FILTER_OPTION_KEYS[id]
        if option_key
          this_year = Find::CycleTimetable.current_year
          next_year = Find::CycleTimetable.next_year
          I18n.t(
            "find.results.filters.all.#{option_key}.#{filter.raw_value}",
            recruitment_cycle_year: this_year,
            next_recruitment_cycle_year: next_year,
            default: filter.formatted_value,
          )
        else
          filter.formatted_value
        end
      end
    end
  end
end
