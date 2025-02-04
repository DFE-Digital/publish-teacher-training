# frozen_string_literal: true

module Geolocation
  class NullStrategy
    def coordinates
      { latitude: nil, longitude: nil, location: nil }
    end
  end
end
