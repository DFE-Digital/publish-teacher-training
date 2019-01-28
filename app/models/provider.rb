# == Schema Information
#
# Table name: provider
#
#  id                   :integer          not null, primary key
#  address4             :text
#  provider_name        :text
#  scheme_member        :text
#  contact_name         :text
#  year_code            :text
#  provider_code        :text
#  provider_type        :text
#  postcode             :text
#  scitt                :text
#  url                  :text
#  address1             :text
#  address2             :text
#  address3             :text
#  email                :text
#  telephone            :text
#  region_code          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  accrediting_provider :text
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
  has_many :enrichments,
           foreign_key: :provider_code,
           primary_key: :provider_code,
           class_name: "ProviderEnrichment"

  scope :changed_since, ->(datetime) do
    if datetime.present?
      left_joins(:sites, :enrichments).where(
        <<~EOSQL,
          provider.updated_at >= :since
            OR site.updated_at >= :since
            OR (provider_enrichment.status = :status
                AND provider_enrichment.updated_at >= :since)
        EOSQL
        since: datetime,
        status: ProviderEnrichment.statuses['published']
      )
    end
  end

  # TODO: filter to published enrichments, maybe rename to published_address_info
  def address_info
    result = valid_enriched_address_info

    if !result.present?
      fields = %w[address1 address2 address3 address4 postcode]

      result = self
        .attributes_before_type_cast
        .slice(*fields)
    end

    # region_code should be present in enrichment regardless
    result['region_code'] = (enrichments.with_address_info.first || self).region_code_before_type_cast

    result
  end

  def valid_enriched_address_info
    fields = %w[address1 address2 address3 address4 postcode]

    result = enrichments.with_address_info.first.present? && enrichments.with_address_info.first
    .attributes_before_type_cast
    .slice(*fields)

    result = !result.present? || fields.any? { |field| result[field].present? } ? result : nil
  end
end
