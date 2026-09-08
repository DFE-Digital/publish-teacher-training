# frozen_string_literal: true

module Geolocation
  # The international mile, exactly. PostGIS returns distances in metres and every
  # caller reports miles, so this is the one place that conversion lives.
  #
  # It was previously spelled out at each call site in two precisions - 1609.344
  # and a truncated 1609.34 - which left the course page and the results card
  # dividing the same distance by different numbers.
  METRES_PER_MILE = 1609.344
end
