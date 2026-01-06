# frozen_string_literal: true

module Geolocation
  # A geocoded address with normalized coordinates.
  #
  # Represents a location resolved from a query string. Wraps the normalized
  # hash returned by {AddressResolver} and provides attribute accessors for
  # coordinate and address data in a provider-agnostic format.
  #
  # @example Query and resolve an address
  #   address = Geolocation::Address.query("London")
  #   # => #<Geolocation::Address latitude=51.5, longitude=-0.1, country="GB">
  #
  #   address.latitude      # => 51.5072178
  #   address.longitude     # => -0.1275862
  #   address.country       # => "GB"
  #   address.postal_code   # => "SW1A 1AA"
  #
  # @attr_reader formatted_address [String] Full formatted address string
  # @attr_reader latitude [Float] Latitude coordinate
  # @attr_reader longitude [Float] Longitude coordinate
  # @attr_reader country [String] Country code (ISO 3166-1 alpha-2)
  # @attr_reader postal_code [String] Postal/ZIP code
  # @attr_reader postal_town [String] Postal town or city name
  # @attr_reader route [String] Street name or route
  # @attr_reader locality [String] City or locality name
  # @attr_reader administrative_area_level_1 [String] State/province/region
  # @attr_reader administrative_area_level_4 [String] District or county
  class Address
    attr_reader :query,
                :formatted_address,
                :latitude,
                :longitude,
                :country,
                :postal_code,
                :postal_town,
                :route,
                :locality,
                :administrative_area_level_1,
                :administrative_area_level_2,
                :administrative_area_level_4,
                :address_types

    # Initialize a new Address.
    #
    # @param formatted_address [String] Full formatted address string
    # @param latitude [Float] Latitude coordinate
    # @param longitude [Float] Longitude coordinate
    # @param country [String, nil] Country code
    # @param postal_code [String, nil] Postal/ZIP code
    # @param postal_town [String, nil] Postal town name
    # @param route [String, nil] Street name
    # @param locality [String, nil] City name
    # @param administrative_area_level_1 [String, nil] State/province
    # @param district [String, nil] District/county
    def initialize(
      query: nil,
      formatted_address: nil,
      latitude: nil,
      longitude: nil,
      country: nil,
      postal_code: nil,
      postal_town: nil,
      route: nil,
      locality: nil,
      administrative_area_level_1: nil,
      administrative_area_level_2: nil,
      administrative_area_level_4: nil,
      address_types: []
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
      @administrative_area_level_2 = administrative_area_level_2
      @administrative_area_level_4 = administrative_area_level_4
      @address_types = address_types
      @query = query.to_s
    end

    # Query and resolve an address from a location string.
    #
    # Delegates to {AddressResolver} to geocode the query and wrap the result
    # in a new Address instance. Uses caching to avoid redundant API calls.
    #
    # @param query_string [String] The location to geocode
    # @param logger [Logger] Rails logger (default: Rails.logger)
    # @param cache [ActiveSupport::Cache::Store] Cache store (default: Rails.cache)
    # @param client [#geocode] Geocoding API client
    # @param cache_expiration [ActiveSupport::Duration] Cache TTL (default: 30.days)
    #
    # @return [Address] A new Address instance with resolved coordinates
    #
    # @example
    #   address = Address.query("Canary wharf")
    #   address.country # => "England"
    def self.query(
      query_string,
      logger: Rails.logger,
      cache: Rails.cache,
      client: GoogleOldPlacesAPI::Client.new,
      cache_expiration: 30.days
    )
      resolver = AddressResolver.new(
        query_string,
        logger:,
        cache:,
        client:,
        cache_expiration:,
      )

      address_data = resolver.call.merge(query: query_string)

      new(**address_data)
    end

    def params
      to_h.merge(short_address:)
    end

    # Export as a hash suitable for caching or form serialization.
    #
    # @return [Hash] Hash with address attributes
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
        administrative_area_level_2:,
        administrative_area_level_4:,
        address_types:,
      }
    end

    def short_address
      return route if train_station?
      return route if university?
      return postal_code if full_postcode?
      return locality if city_only?
      return [postal_code, postal_town].compact.join(", ") if partial_postcode?
      return [route, postal_town].compact.join(", ") if landmark?
      return [postal_code, postal_town].compact.join(", ") if postcode_area?
      return [administrative_area_level_4, postal_town].compact.join(", ") if district_only?
      return [route, postal_town].compact.join(", ") if street_name?
      return administrative_area_level_2 if has_type?("administrative_area_level_2")

      formatted_address.to_s.gsub(/, UK/, "")
    end

  private

    def full_postcode?
      postal_code.present? && UKPostcode.parse(query).full_valid?
    rescue StandardError
      false
    end

    def city_only?
      locality.present? && postal_code.blank? && route.blank? && administrative_area_level_4.blank?
    end

    def partial_postcode?
      postal_code.present? && !full_postcode? && !postcode_area?
    end

    def landmark?
      route.present? && postal_code.present? && route != locality
    end

    def postcode_area?
      postal_code.present? && postal_town.present?
    end

    def district_only?
      administrative_area_level_4.present? && postal_code.blank? && route.blank?
    end

    def train_station?
      route.present? && route.match?(/(station|terminus|platform)/i) && postal_code.present?
    end

    def university?
      route.present? && route.match?(/university|college|school/i)
    end

    def street_name?
      route.present? && postal_town.present? && postal_code.blank?
    end

    def has_type?(*types)
      types.any? { |type| address_types.include?(type) }
    end
  end
end
