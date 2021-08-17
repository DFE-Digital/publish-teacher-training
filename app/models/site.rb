class Site < ApplicationRecord
  MAIN_SITE = "main site".freeze

  include PostcodeNormalize
  include RegionCode
  include TouchProvider
  include Discard::Model

  class DiscardError < StandardError; end

  POSSIBLE_CODES = (("A".."Z").to_a + ("0".."9").to_a + ["-"]).freeze
  EASILY_CONFUSED_CODES = %w[1 I 0 O -].freeze # these ought to be assigned last
  DESIRABLE_CODES = (POSSIBLE_CODES - EASILY_CONFUSED_CODES).freeze

  before_validation :assign_code, unless: :persisted?

  before_discard do
    raise DiscardError, "cannot delete the last location" if provider.sites.count == 1
  end

  audited associated_with: :provider

  belongs_to :provider

  validates :location_name, uniqueness: { scope: :provider_id }
  validates :location_name,
            :address1,
            :postcode,
            presence: true
  validates :postcode, postcode: true
  validates :code, uniqueness: { scope: :provider_id, case_sensitive: false },
                   format: { with: /\A[A-Z0-9\-]+\z/, message: "must contain only A-Z, 0-9 or -" },
                   presence: true

  validates :urn, reference_number_format: { allow_blank: true, minimum: 5, maximum: 6, message: "^URN must be 5 or 6 numbers" }

  acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude

  scope :not_geocoded, -> { where(latitude: nil, longitude: nil) }

  attr_accessor :skip_geocoding
  after_commit :geocode_site, unless: :skip_geocoding

  delegate :recruitment_cycle, :provider_code, to: :provider, allow_nil: true
  delegate :after_2021?, to: :recruitment_cycle, allow_nil: true, prefix: :recruitment_cycle

  def geocode_site
    GeocodeJob.perform_later("Site", id) if needs_geolocation?
  end

  def needs_geolocation?
    full_address.present? && (
    latitude.nil? || longitude.nil? || address_changed?
  )
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
    self.code ||= Sites::CodeGenerator.call(provider: provider)
  end

  def to_s
    "#{location_name} (code: #{code})"
  end
end
