module RegionCode
  extend ActiveSupport::Concern
  included do
    # These correspond to the first-level NUTS regions for the UK (minus Northern Ireland)
    # https://en.wikipedia.org/wiki/First-level_NUTS_of_the_European_Union#United_Kingdom

    enum region_code: {
      no_region: 0,
      london: 1,
      south_east: 2,
      south_west: 3,
      wales: 4,
      west_midlands: 5,
      east_midlands: 6,
      eastern: 7,
      north_west: 8,
      yorkshire_and_the_humber: 9,
      north_east: 10,
      scotland: 11,
    }
  end
end
