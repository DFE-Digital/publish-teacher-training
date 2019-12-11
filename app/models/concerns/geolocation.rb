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
      saved_change_to_address1? ||
        saved_change_to_address2? ||
        saved_change_to_address3? ||
        saved_change_to_address4? ||
        saved_change_to_postcode?
    end
  end
end
