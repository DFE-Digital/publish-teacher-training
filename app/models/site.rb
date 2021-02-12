class Site < ApplicationRecord
  MAIN_SITE = "main site".freeze

  include PostcodeNormalize
  include RegionCode
  include TouchProvider

  POSSIBLE_CODES = (("A".."Z").to_a + ("0".."9").to_a + ["-"]).freeze
  EASILY_CONFUSED_CODES = %w[1 I 0 O -].freeze # these ought to be assigned last
  DESIRABLE_CODES = (POSSIBLE_CODES - EASILY_CONFUSED_CODES).freeze

  before_validation :assign_code, unless: :persisted?

  audited associated_with: :provider

  belongs_to :provider

  has_and_belongs_to_many :establishments_matched_by_postcode,
                          join_table: :gias_establishment_site_postcode_matches,
                          class_name: "GIASEstablishment",
                          association_foreign_key: "establishment_id"

  validates :location_name, uniqueness: { scope: :provider_id }
  validates :location_name,
            :address1,
            :postcode,
            presence: true
  validates :postcode, postcode: true
  validates :code, uniqueness: { scope: :provider_id, case_sensitive: false },
                   inclusion: { in: POSSIBLE_CODES, message: "must be A-Z, 0-9 or -" },
                   presence: true

  acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude

  scope :not_geocoded, -> { where(latitude: nil, longitude: nil) }

  attr_accessor :skip_geocoding
  after_commit :geocode_site, unless: :skip_geocoding
  after_commit :add_travel_to_work_area_and_london_borough, if: :needs_travel_to_work_area_and_london_borough_updated?

  def geocode_site
    GeocodeJob.perform_later("Site", id) if needs_geolocation?
  end

  def needs_geolocation?
    full_address.present? && (
    latitude.nil? || longitude.nil? || address_changed?
    )
  end

  def add_travel_to_work_area_and_london_borough
    TravelToWorkAreaAndLondonBoroughJob.perform_later(id)
  end

  def full_address
    address = [address1, address2, address3, address4, postcode]

    unless location_name.downcase == MAIN_SITE
      address.unshift(location_name)
    end

    return "" if address.all?(&:blank?)

    address.compact.join(", ")
  end

  def address_changed?
    saved_change_to_location_name? ||
      saved_change_to_address1? ||
      saved_change_to_address2? ||
      saved_change_to_address3? ||
      saved_change_to_address4? ||
      saved_change_to_postcode?
  end

  def recruitment_cycle
    provider.recruitment_cycle
  end

  def assign_code
    self.code ||= pick_next_available_code(available_codes: provider&.unassigned_site_codes)
  end

  def to_s
    "#{location_name} (code: #{code})"
  end

private

  def pick_next_available_code(available_codes: [])
    available_desirable_codes = available_codes & DESIRABLE_CODES
    available_undesirable_codes = available_codes & EASILY_CONFUSED_CODES
    available_desirable_codes.sample || available_undesirable_codes.sample
  end

  def needs_travel_to_work_area_and_london_borough_updated?
    latitude.present? &&
      longitude.present? &&
      (
        saved_change_to_longitude? ||
        saved_change_to_latitude?
      )
  end
end
