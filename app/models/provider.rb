# == Schema Information
#
# Table name: provider
#
#  id            :integer          not null, primary key
#  address4      :text
#  provider_name :text
#  scheme_member :text
#  contact_name  :text
#  year_code     :text
#  provider_code :text
#  provider_type :text
#  postcode      :text
#  scitt         :text
#  url           :text
#  address1      :text
#  address2      :text
#  address3      :text
#  email         :text
#  telephone     :text
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
    @last_enrichment = enrichments.with_address_info.last
    @address_info = (@last_enrichment || self)
      .slice('address1', 'address2', 'address3', 'address4', 'postcode')
    @region_code = @last_enrichment.present? ? @last_enrichment[:region_code] : self.region_code_before_type_cast
    @address_info[:region_code] = @region_code
    @address_info
  end
end
