# frozen_string_literal: true

module Find
  module RecentSearches
    class SummaryCardComponent < ViewComponent::Base
      def initialize(recent_search:)
        super
        @recent_search = recent_search
        @attrs = recent_search.search_attributes || {}
      end

      def title
        render(Find::Courses::SearchTitleComponent.new(
                 subjects: resolved_subject_names,
                 location_name: location_display_name,
                 radius: @recent_search.radius,
                 search_attributes: @attrs,
               ))
      end

      def filter_tags
        @filter_tags ||= build_filter_tags
      end

      def search_again_path
        helpers.find_results_path(@recent_search.search_params)
      end

    private

      def resolved_subject_names
        return [] if @recent_search.subjects.blank?

        Subject.where(subject_code: @recent_search.subjects).pluck(:subject_name)
      end

      def location_display_name
        @attrs["location"] || @attrs["formatted_address"]
      end

      def build_filter_tags
        tags = []
        tags << provider_tag if @attrs["provider_name"].present?
        tags.concat(resolved_subject_names)
        tags << location_tag if location_display_name.present?
        tags << visa_tag if @attrs["can_sponsor_visa"].present?
        tags.concat(funding_tags)
        tags << send_tag if @attrs["send_courses"].present?
        tags << level_tag if @attrs["level"].present?
        tags.compact
      end

      def location_tag
        radius = @recent_search.radius
        name = location_display_name
        if radius.present?
          I18n.t("find.recent_searches.summary_card.location_with_radius", radius: radius, location: name)
        else
          name
        end
      end

      def visa_tag
        I18n.t("find.recent_searches.summary_card.visa_sponsorship")
      end

      def funding_tags
        Array(@attrs["funding"]).filter_map do |f|
          I18n.t("find.recent_searches.summary_card.funding.#{f}", default: nil)
        end
      end

      def send_tag
        I18n.t("find.recent_searches.summary_card.send_courses")
      end

      def provider_tag
        @attrs["provider_name"]
      end

      def level_tag
        @attrs["level"].humanize
      end
    end
  end
end
