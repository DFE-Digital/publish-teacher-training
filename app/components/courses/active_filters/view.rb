module Courses
  module ActiveFilters
    # The removable chips summarising which filters are applied, plus the link
    # that clears them all.
    #
    # Shared by Find and Publish, which list different things at different URLs:
    # the caller passes a +path_builder+ that turns a params hash into a link
    # back to its own list, so this component never names a route itself.
    class View < ViewComponent::Base
      DEFAULT_CLEAR_ALL_TEXT = "Clear all".freeze

      attr_reader :active_filters, :search_params, :path_builder, :clear_all_path, :clear_all_text

      def initialize(active_filters:, path_builder:, clear_all_path:, search_params: {}, clear_all_text: DEFAULT_CLEAR_ALL_TEXT)
        super()

        @active_filters = active_filters
        @search_params = search_params
        @path_builder = path_builder
        @clear_all_path = clear_all_path
        @clear_all_text = clear_all_text
      end

      def render?
        active_filters.present?
      end

      def remove_path(filter)
        path_builder.call(search_params.to_h.merge(filter.remove_params))
      end
    end
  end
end
