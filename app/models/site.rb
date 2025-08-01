# frozen_string_literal: true

class Site < ApplicationRecord
  MAIN_SITE = "main site"
  URN_2022_REQUIREMENTS_REQUIRED_FROM = 2022

  include PostcodeNormalize
  include RegionCode
  include TouchProvider
  include Discard::Model

  POSSIBLE_CODES = (("A".."Z").to_a + ("0".."9").to_a + ["-"]).freeze
  EASILY_CONFUSED_CODES = %w[1 I 0 O -].freeze # these ought to be assigned last
  DESIRABLE_CODES = (POSSIBLE_CODES - EASILY_CONFUSED_CODES).freeze

  before_validation :assign_code, unless: :persisted?

  audited associated_with: :provider

  has_many :site_statuses, dependent: :destroy
  has_many :study_site_placements, dependent: :destroy

  belongs_to :provider

  enum :site_type, {
    school: 0,
    study_site: 1,
  }

  enum :added_via, {
    publish_interface: "publish_interface",
    register_import: "register_import",
  }

  validates :location_name, uniqueness: { scope: %i[provider_id site_type],
                                          message: lambda { |object, _data|
                                            "This #{object.site_type.humanize.downcase} has already been added"
                                          } }
  validates :location_name,
            :address1,
            :postcode,
            presence: true

  # NOTE: Existing dataset causing cascading issues (from site_status/course) hence it is enforced independently differently
  validates :town, presence: true, on: %i[create], unless: -> { site_type == "school" }

  validates :postcode, postcode: true

  validates :urn, reference_number_format: { allow_blank: true, minimum: 5, maximum: 6, message: "Site URN must be 5 or 6 numbers" }

  acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude

  scope :not_geocoded, -> { where(latitude: nil, longitude: nil) }

  attr_accessor :skip_geocoding

  after_commit :geocode_site, unless: :skip_geocoding

  delegate :recruitment_cycle, :provider_code, to: :provider, allow_nil: true
  delegate :after_2021?, to: :recruitment_cycle, allow_nil: true, prefix: :recruitment_cycle

  def has_no_course?
    Course.kept.includes(:sites).where(sites: { id: }).none?
  end

  def geocode_site
    GeocodeJob.perform_later("Site", id) if needs_geolocation?
  end

  def needs_geolocation?
    full_address.present? && (
    latitude.nil? || longitude.nil? || address_changed?
  )
  end

  def full_address
    address = [address1, address2, address3, town, address4, postcode]

    address.unshift(location_name) unless location_name.downcase == MAIN_SITE

    return "" if address.all?(&:blank?)

    address.compact_blank.join(", ")
  end

  def address
    [address1, address2, address3, town, address4, postcode]
  end

  def address_changed?
    saved_change_to_location_name? ||
      saved_change_to_address1? ||
      saved_change_to_address2? ||
      saved_change_to_address3? ||
      saved_change_to_town? ||
      saved_change_to_address4? ||
      saved_change_to_postcode?
  end

  def assign_code
    self.code ||= Sites::CodeGenerator.call(provider:)
  end

  def to_s
    "#{location_name} (code: #{code})"
  end
end
