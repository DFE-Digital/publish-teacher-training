class Site < ApplicationRecord
  self.table_name = "site"

  belongs_to :provider
end
