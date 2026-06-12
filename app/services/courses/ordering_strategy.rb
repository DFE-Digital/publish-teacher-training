module Courses
  class OrderingStrategy
    DEFAULT_ORDER = "course_name_ascending".freeze
    LOCATED_ORDER = "distance".freeze

    # The default order for a given location — used by callers (SearchForm,
    # SearchParamDefaults, HashExtractor) that need to know "what would the
    # default be?" without going through the full strategy.
    def self.default_for(search_location)
      search_location.located? ? LOCATED_ORDER : DEFAULT_ORDER
    end

    def initialize(search_location:, funding:, current_order:)
      @search_location = search_location
      @funding = funding
      @current_order = current_order
    end

    def call
      return DEFAULT_ORDER if distance_without_location?
      return default_order if should_reset_to_default?

      @current_order.presence || default_order
    end

  private

    def default_order
      self.class.default_for(@search_location)
    end

    def should_reset_to_default?
      @current_order.blank? || fee_order_without_fee_funding?
    end

    def distance_without_location?
      @current_order == LOCATED_ORDER && !@search_location.located?
    end

    def fee_order_without_fee_funding?
      @current_order&.match?(/fee/) && @funding&.exclude?("fee")
    end
  end
end
