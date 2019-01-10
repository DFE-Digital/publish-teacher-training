class Provider < ApplicationRecord
  self.table_name = "provider"

  enum provider_type: {
    "SCITT" => "B",
    "Lead school" => "Y",
    "University" => "O",
    "??" => "",
    "Invalid value" => "0", # there is only one of these in the data
  }

  has_and_belongs_to_many :organisations, join_table: :organisation_provider

  has_many :sites
  has_many :enrichments, foreign_key: :provider_code, primary_key: :provider_code, class_name: "ProviderEnrichment"
  def address_info
    (enrichments.with_address_info.last || self)
      .slice('address1', 'address2', 'address3', 'address4', 'postcode')
  end
end
