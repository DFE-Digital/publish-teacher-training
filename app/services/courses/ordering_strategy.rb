module Courses
  class OrderingStrategy
    DEFAULT_ORDER = "course_name_ascending".freeze

    def initialize(location:, funding:, current_order:)
      @location = location
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
