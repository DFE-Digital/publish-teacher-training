class Site < ApplicationRecord
  self.table_name = "site"

  enum region_code: {
    'London' => 1,
    'South East' => 2,
    'South West' => 3,
    'Wales' => 4,
    'West Midlands' => 5,
    'East Midlands' => 6,
    'Eastern' => 7,
    'North West' => 8,
    'Yorkshire & the Humber' => 9,
    'North East' => 10,
    'Scotland' => 11,
  }

  belongs_to :provider
end
