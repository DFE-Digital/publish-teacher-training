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
#  last_published_at    :datetime
#  changed_at           :datetime         not null
#  opted_in             :boolean          default(FALSE)
#

class Provider < ApplicationRecord
  include RegionCode
  include ChangedAt

  enum provider_type: {
    scitt: "B",
    lead_school: "Y",
    university: "O",
    unknown: "",
    invalid_value: "0", # there is only one of these in the data
  }

  has_and_belongs_to_many :organisations, join_table: :organisation_provider
  has_many :users, through: :organisations

  has_many :sites
  has_many :enrichments,
           foreign_key: :provider_code,
           primary_key: :provider_code,
           class_name: "ProviderEnrichment"
  has_many :courses

  scope :changed_since, ->(datetime) do
    if datetime.present?
      where("last_published_at >= ?", datetime)
    else
      where("last_published_at is not null")
    end.order(:last_published_at, :id)
  end

  scope :opted_in, -> { where(opted_in: true) }

  # TODO: filter to published enrichments, maybe rename to published_address_info
  def address_info
    (enrichments.latest_created_at.with_address_info.first || self)
      .attributes_before_type_cast
      .slice('address1', 'address2', 'address3', 'address4', 'postcode', 'region_code')
  end
end
