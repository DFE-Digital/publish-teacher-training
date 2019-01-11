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

  def address
    if enrichments.present?
      attrs = enrichments.last.json_data
      {
        "address1" => attrs["Address1"],
        "address2" => attrs["Address2"],
        "address3" => attrs["Address3"],
        "address4" => attrs["Address4"],
        "postcode" => attrs["Postcode"]
      }
    else
      attributes
    end
  end

  def address1
    address["address1"]
  end

  def address2
    address["address2"]
  end

  def address3
    address["address3"]
  end

  def address4
    address["address4"]
  end

  def postcode
    address["postcode"]
  end
end
