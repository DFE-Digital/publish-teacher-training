module Courses
  class OrderingStrategy
    DEFAULT_ORDER = "course_name_ascending".freeze

    SORT_BY_MAPPING = {
      "course_asc" => "course_name_ascending",
      "course_desc" => "course_name_descending",
      "provider_asc" => "provider_name_ascending",
      "provider_desc" => "provider_name_descending",
    }.freeze

    def initialize(location:, funding:, current_order:, sortby:, find_filtering_and_sorting:)
      @location = location
      @funding = funding
      @current_order = current_order
      @sortby = sortby
      @find_filtering_and_sorting = find_filtering_and_sorting
    end

    def call
      return legacy_order if !@find_filtering_and_sorting || @sortby.present?

      new_feature_order
    end

  private

    def legacy_order
      SORT_BY_MAPPING[@sortby] || @current_order
    end

    def new_feature_order
      return DEFAULT_ORDER if distance_without_location?
      return default_order if should_reset_to_default?

      @current_order.presence || default_order
    end

    def default_order
      @location.present? ? "distance" : DEFAULT_ORDER
    end

    def should_reset_to_default?
      @current_order.blank? || fee_order_without_fee_funding?
    end

    def distance_without_location?
      @current_order == "distance" && @location.blank?
    end

    def fee_order_without_fee_funding?
      @current_order&.match?(/fee/) && @funding&.exclude?("fee")
    end
  end
end
