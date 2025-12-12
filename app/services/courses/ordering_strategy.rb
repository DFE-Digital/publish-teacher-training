module Courses
  class OrderingStrategy
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

    def legacy_order
      SORT_BY_MAPPING[@sortby] || @current_order
    end

    def new_feature_order
      return "distance" if @location.present? && @current_order.blank?
      return "course_name_ascending" if current_order_fee? && @funding&.exclude?("fee")
      return "course_name_ascending" if @current_order.blank?
      return "course_name_ascending" if @location.blank? && @current_order == "distance"

      @current_order
    end

    def current_order_fee?
      @current_order&.match?(/fee/)
    end

    SORT_BY_MAPPING = {
      "course_asc" => "course_name_ascending",
      "course_desc" => "course_name_descending",
      "provider_asc" => "provider_name_ascending",
      "provider_desc" => "provider_name_descending",
    }.freeze
  end
end
