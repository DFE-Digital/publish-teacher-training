# frozen_string_literal: true

module Geolocation
  class CoordinatesResult
    attr_reader :formatted_address,
                :latitude,
                :longitude,
                :country,
                :postal_code,
                :postal_town,
                :route,
                :locality,
                :administrative_area_level_1,
                :administrative_area_level_4,
                :address_types

    def initialize(
      formatted_address: nil,
      latitude: nil,
      longitude: nil,
      country: nil,
      postal_code: nil,
      postal_town: nil,
      route: nil,
      locality: nil,
      administrative_area_level_1: nil,
      administrative_area_level_4: nil,
      address_types: nil
    )
      @formatted_address = formatted_address
      @latitude = latitude
      @longitude = longitude
      @country = country
      @postal_code = postal_code
      @postal_town = postal_town
      @route = route
      @locality = locality
      @administrative_area_level_1 = administrative_area_level_1
      @administrative_area_level_4 = administrative_area_level_4
      @address_types = address_types
    end

    def to_h
      {
        formatted_address:,
        latitude:,
        longitude:,
        country:,
        postal_code:,
        postal_town:,
        route:,
        locality:,
        administrative_area_level_1:,
        administrative_area_level_4:,
        address_types:,
      }
    end
  end
end
