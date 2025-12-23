module Courses
  class DefaultRadius
    SMALL_RADIUS = 10
    DEFAULT_RADIUS = 50
    SMALL_RADIUS_TYPES = %w[postal_code street_address route sublocality locality].freeze

    def initialize(location:, formatted_address:, address_types:)
      @location = location
      @formatted_address = formatted_address
      @address_types = address_types
    end

    def call
      return nil if location.blank?

      if london?
        london_radius
      elsif locality?
        SMALL_RADIUS
      else
        DEFAULT_RADIUS
      end
    end

  private

    attr_reader :location, :formatted_address, :address_types

    LONDON = "London".freeze
    def london?
      formatted_address.to_s.gsub(/, UK/, "") == LONDON
    end

    def locality?
      # @see https://developers.google.com/maps/documentation/geocoding/requests-geocoding#Types
      address_types && (address_types & SMALL_RADIUS_TYPES).present?
    end

    def london_radius
      FeatureFlag.active?(:find_filtering_and_sorting) ? 20 : 15
    end
  end
end
