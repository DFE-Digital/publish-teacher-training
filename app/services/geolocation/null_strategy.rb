# frozen_string_literal: true

module Geolocation
  class NullStrategy
    def coordinates
      { formatted_address: nil, latitude: nil, longitude: nil, types: [] }
    end
  end
end
