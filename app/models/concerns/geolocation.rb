module Geolocation
  extend ActiveSupport::Concern
  included do
    geocoded_by :full_address

    def needs_geolocation?
      full_address.present? && (
        latitude.nil? || longitude.nil? || address_changed?
      )
    end

    def full_address
      [address1, address2, address3, address4, postcode].compact.join(", ")
    end

    def address_changed?
      address1_changed? || address2_changed? || address3_changed? || address4_changed? || postcode_changed?
    end
  end
end
