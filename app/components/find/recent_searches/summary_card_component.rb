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
        @filter_tags ||= ::Courses::ActiveFilters::HashExtractor.new(
          @attrs.merge("radius" => @recent_search.radius),
          subject_names: resolved_subject_names,
          provider_name: @attrs["provider_name"],
        ).call
      end

      def search_again_path
        helpers.find_results_path(@recent_search.search_params)
      end

      def email_alert_path
        helpers.new_find_candidate_email_alert_path(@recent_search.search_params.merge(return_to: "recent_searches"))
      end

    private

      def resolved_subject_names
        @resolved_subject_names ||=
          if @recent_search.subjects.present?
            Subject.where(subject_code: @recent_search.subjects).pluck(:subject_name)
          else
            []
          end
      end

      def location_display_name
        @attrs["location"] || @attrs["formatted_address"]
      end
    end
  end
end
