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
#

class Provider < ApplicationRecord
  include RegionCode
  include ChangedAt

  has_associated_audits
  audited except: :changed_at

  enum provider_type: {
    scitt: "B",
    lead_school: "Y",
    university: "O",
    unknown: "",
    invalid_value: "0", # there is only one of these in the data
  }

  enum accrediting_provider: {
    accredited_body: 'Y',
    not_an_accredited_body: 'N',
  }

  has_and_belongs_to_many :organisations, join_table: :organisation_provider
  has_many :users, through: :organisations

  has_many :sites
  has_many :enrichments,
           foreign_key: :provider_code,
           primary_key: :provider_code,
           class_name: "ProviderEnrichment"
  has_one :latest_published_enrichment,
          -> { published.latest_published_at },
          foreign_key: :provider_code,
          primary_key: :provider_code,
          class_name: "ProviderEnrichment"
  has_many :courses
  has_one :ucas_preferences, class_name: 'ProviderUCASPreference'
  has_many :contacts

  scope :changed_since, ->(timestamp) do
    if timestamp.present?
      where("provider.changed_at > ?", timestamp)
    else
      where("changed_at is not null")
    end.order(:changed_at, :id)
  end

  scope :in_order, -> { order(:provider_name) }

  # For some reason organisations is a has_and_belongs_to_many. Until we fix
  # this and set it to a singular relationship, we should make sure we don't
  # get any extra data in our db.
  validates_length_of :organisations, maximum: 1

  # Currently Provider#contact_info isn't used but will likely be needed when
  # we need to expose the candidate-facing contact info.
  #
  # When the time comes:
  # - rename this method to reflect that it's the candidate-facing contact
  # - resurrect the tests which were stripped from models/provider_spec.rb
  #
  # def contact_info
  #   self
  #     .attributes_before_type_cast
  #     .slice('address1', 'address2', 'address3', 'address4', 'postcode', 'region_code', 'telephone', 'email')
  # end

  # This is used by the providers index; it is a replacement for `.includes(:courses)`,
  # but it only fetches the counts for the associated courses. By not fetching all the
  # course objects for 1000+ providers, the db query runs much faster, and the view spends
  # less time rendering because there's less data to comb through.
  def self.include_courses_counts
    joins(
      %{
        LEFT OUTER JOIN (
          SELECT b.provider_id, COUNT(*) courses_count
          FROM course b
          GROUP BY b.provider_id
        ) a ON a.provider_id = provider.id
      }
    ).select("provider.*, COALESCE(a.courses_count, 0) AS included_courses_count")
  end

  def courses_count
    self.respond_to?("included_courses_count") ? included_courses_count : courses.size
  end

  def update_changed_at(timestamp: Time.now.utc)
    # Changed_at represents changes to related records as well as provider
    # itself, so we don't want to alter the semantics of updated_at which
    # represents changes to just the provider record.
    update_columns changed_at: timestamp
  end

  def recruitment_cycle
    "2019"
  end

  def unassigned_site_codes
    Site::POSSIBLE_CODES - sites.pluck(:code)
  end

  def can_add_more_sites?
    sites.size < Site::POSSIBLE_CODES.size
  end

  def external_contact_info
    attribute_names = %w[
      address1
      address2
      address3
      address4
      postcode
      region_code
      telephone
      email
    ]

    if latest_published_enrichment
      latest_published_enrichment.attributes.slice(*(attribute_names + %w[website]))
    else
      attributes.slice(*attribute_names).merge('website' => url)
    end
  end

  def to_s
    "#{provider_name} (#{provider_code})"
  end
end
