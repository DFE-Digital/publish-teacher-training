# == Schema Information
#
# Table name: provider
#
#  id                   :integer          not null, primary key
#  provider_name        :text
#  provider_code        :text
#  provider_type        :text
#  scheme_member        :text
#  year_code            :text
#  scitt                :text
#  accrediting_provider :text
#  contact_name         :text
#  address1             :text
#  address2             :text
#  address3             :text
#  address4             :text
#  postcode             :text
#  email                :text
#  telephone            :text
#  url                  :text
#

class Provider < ApplicationRecord
  self.table_name = "provider"

  include RegionCode

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
      .attributes_before_type_cast
      .slice('address1', 'address2', 'address3', 'address4', 'postcode', 'region_code')
  end
end
