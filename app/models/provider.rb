class Provider < ApplicationRecord
  self.table_name = "provider"

  has_and_belongs_to_many :organisations, join_table: :organisation_provider

  has_many :sites
end
