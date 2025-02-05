# frozen_string_literal: true

module Geolocation
  class Resolver
    def initialize(place_id: nil, query: nil)
      @place_id = place_id
      @query = query
    end

    def call
      strategy = if @place_id.present?
                   Geolocation::LocationIdStrategy.new(@place_id)
                 elsif @query.present?
                   Geolocation::LocationNameStrategy.new(@query)
                 else
                   Geolocation::NullStrategy.new
                 end

      strategy.coordinates
    end
  end
end
