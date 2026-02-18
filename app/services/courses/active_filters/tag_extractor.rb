# frozen_string_literal: true

module Courses
  module ActiveFilters
    class TagExtractor
      TRANSLATABLE_FILTERS = [
        { key: "can_sponsor_visa", type: :boolean, i18n_key: "visa_sponsorship" },
        { key: "funding", type: :array },
        { key: "study_types", type: :array },
        { key: "qualifications", type: :array },
        { key: "minimum_degree_required", type: :scalar, skip_default: "show_all_courses" },
        { key: "start_date", type: :array },
        { key: "send_courses", type: :boolean, i18n_key: "send_courses" },
      ].freeze

      def initialize(attrs, subject_names: [], i18n_scope: "find.recent_searches.summary_card")
        @attrs = attrs.to_h.transform_keys(&:to_s)
        @subject_names = subject_names
        @i18n_scope = i18n_scope
      end

      def call
        tags = []
        tags << @attrs["provider_name"] if @attrs["provider_name"].present?
        tags.concat(@subject_names)
        tags.concat(location_tags)
        TRANSLATABLE_FILTERS.each { |filter| tags.concat(translate_filter(filter)) }
        tags << level_tag
        tags.compact
      end

    private

      def location_tags
        name = @attrs["location"] || @attrs["formatted_address"]
        return [] if name.blank?

        radius = @attrs["radius"]
        if radius.present?
          [I18n.t("#{@i18n_scope}.location_with_radius", radius: radius, location: name)]
        else
          [name]
        end
      end

      def translate_filter(filter)
        value = @attrs[filter[:key]]
        return [] if value.blank?

        case filter[:type]
        when :boolean
          [I18n.t("#{@i18n_scope}.#{filter[:i18n_key]}")]
        when :array
          Array(value).filter_map { |v| I18n.t("#{@i18n_scope}.#{filter[:key]}.#{v}", default: nil) }
        when :scalar
          return [] if value == filter[:skip_default]

          [I18n.t("#{@i18n_scope}.#{filter[:key]}.#{value}", default: nil)].compact
        end
      end

      def level_tag
        level = @attrs["level"]
        return if level.blank? || level == "all"

        level.humanize
      end
    end
  end
end
