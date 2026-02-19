# frozen_string_literal: true

module Find
  module RecentSearches
    class FilterTagsComponent < ViewComponent::Base
      attr_reader :active_filters

      def initialize(active_filters:)
        super
        @active_filters = active_filters
      end

      def render?
        @active_filters.present?
      end
    end
  end
end
