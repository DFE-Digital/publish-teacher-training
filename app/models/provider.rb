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
#  recruitment_cycle_id :integer          not null
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

  belongs_to :recruitment_cycle

  has_and_belongs_to_many :organisations, join_table: :organisation_provider
  has_many :users, through: :organisations

  has_many :sites
  has_one :latest_enrichment,
          class_name: "ProviderEnrichment" do
    enrichments.latest_created_at
  end

  has_many :enrichments,
           class_name: "ProviderEnrichment",
           inverse_of: 'provider' do
             def find_or_initialize_draft
               # This is a ruby search as opposed to an AR search, because calling `draft`
               # will return a new instance of a ProviderEnrichment object which is different
               # to the ones in the cached `enrichments` association. This makes checking
               # for validations later down non-trivial.
               latest_draft_enrichment = select(&:draft?).last

               latest_draft_enrichment.presence || new(new_draft_attributes)
             end

             def new_draft_attributes
               latest_published_enrichment = latest_created_at.published.first
               new_enrichments_attributes = { status: :draft }.with_indifferent_access

               if latest_published_enrichment.present?
                 published_enrichment_attributes = latest_published_enrichment.dup.attributes.with_indifferent_access
                   .except(:json_data, :status)

                 new_enrichments_attributes.merge!(published_enrichment_attributes)
               end

               new_enrichments_attributes
             end
           end

  has_one :latest_published_enrichment,
          -> { published.latest_published_at },
          class_name: "ProviderEnrichment",
          inverse_of: 'provider'
  has_many :courses, -> { kept }
  has_one :ucas_preferences, class_name: 'ProviderUCASPreference'
  has_many :contacts
  has_many :accredited_courses,
           class_name: 'Course',
           foreign_key: :accrediting_provider_code,
           primary_key: :provider_code,
           inverse_of: :accrediting_provider

  has_many :accrediting_providers, -> { distinct }, through: :courses

  scope :changed_since, ->(timestamp) do
    if timestamp.present?
      where("provider.changed_at > ?", timestamp)
    else
      where("changed_at is not null")
    end.order(:changed_at, :id)
  end

  scope :in_order, -> { order(:provider_name) }

  validate :validate_enrichment_publishable, on: :publish
  validate :validate_enrichment

  after_validation :remove_unnecessary_enrichments_validation_message

  def syncable_courses
    courses.select(&:syncable?)
  end

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

  def publish_enrichment(current_user)
    enrichments.draft.each do |enrichment|
      enrichment.publish(current_user)
    end
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

    if enrichments.last
      enrichments.last.attributes.slice(*(attribute_names + %w[website]))
    else
      attributes.slice(*attribute_names).merge('website' => url)
    end
  end

  def content_status
    newest_enrichment = enrichments.latest_created_at.first

    if newest_enrichment.nil?
      :empty
    elsif newest_enrichment.published?
      :published
    elsif newest_enrichment.has_been_published_before?
      :published_with_unpublished_changes
    else
      :draft
    end
  end

  def last_published_at
    newest_enrichment = enrichments.latest_created_at.first
    newest_enrichment&.last_published_at
  end

  # This reflects the fact that organisations should actually be a has_one.
  def organisation
    organisations.first
  end

  def to_s
    "#{provider_name} (#{provider_code})"
  end

  def copy_to_recruitment_cycle(new_recruitment_cycle)
    new_provider = new_recruitment_cycle
                      .providers
                      .find_by(provider_code: self.provider_code)
    providers_count = 0
    unless new_provider
      providers_count = 1
      new_provider = self.dup
      new_provider.organisations << self.organisations
      new_provider.ucas_preferences = self.ucas_preferences.dup
      new_provider.contacts << self.contacts.map(&:dup)
      new_recruitment_cycle.providers << new_provider
    end

    # Order is important here. Sites should be copied over before courses
    # so that courses can link up to the correct sites in the new provider.
    sites_count = copy_sites_to_new_provider(new_provider)
    courses_count = copy_courses_to_new_provider(new_provider)

    {
      providers: providers_count,
      sites: sites_count,
      courses: courses_count
    }
  end

  def copy_courses_to_new_provider(new_provider)
    courses_count = 0

    courses.each do |course|
      courses_count += 1 if course.copy_to_provider(new_provider)
    end

    courses_count
  end

  def copy_sites_to_new_provider(new_provider)
    sites_count = 0

    self.sites.each do |site|
      sites_count += 1 if site.copy_to_provider(new_provider)
    end

    sites_count
  end

  def publishable?
    valid? :publish
  end

  def accredited_bodies
    accrediting_providers.map do |ap|
      accrediting_provider_entry = latest_enrichment&.accrediting_provider_enrichment(ap.provider_code)

      # map() to this hash:
      {
        provider_name: ap.provider_name,
        provider_code: ap.provider_code,
        description: accrediting_provider_entry.present? ? accrediting_provider_entry['Description'] : ""
      }
    end
  end

private

  def add_enrichment_errors(enrichment)
    enrichment.errors.messages.map do |field, _error|
      # `full_messages_for` here will remove any `^`s defined in the validator or en.yml.
      # We still need it for later, so re-add it.
      # jsonapi_errors will throw if it's given an array, so we call `.first`.
      message = "^" + enrichment.errors.full_messages_for(field).first.to_s
      errors.add field.to_sym, message
    end
  end

  def validate_enrichment(validation_scope = nil)
    latest_enrichment = enrichments.select(&:draft?).last
    return if latest_enrichment.blank?

    latest_enrichment.valid? validation_scope
    add_enrichment_errors(latest_enrichment)
  end

  def validate_enrichment_publishable
    validate_enrichment :publish
  end

  def remove_unnecessary_enrichments_validation_message
    self.errors.delete :enrichments if self.errors[:enrichments] == ['is invalid']
  end
end
