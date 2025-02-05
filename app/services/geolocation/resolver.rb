# frozen_string_literal: true

module Geolocation
  class Resolver
    def initialize(location_id: nil, location: nil)
      @location_id = location_id
      @location = location
    end

    def call
      strategy = if @location_id.present?
                   Geolocation::LocationIdStrategy.new(@location_id)
                 elsif @location.present?
                   Geolocation::LocationNameStrategy.new(@location)
                 else
                   Geolocation::NullStrategy.new
                 end

      strategy.coordinates
    end
  end
end
