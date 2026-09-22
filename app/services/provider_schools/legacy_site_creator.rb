# frozen_string_literal: true

module ProviderSchools
  # Writes the legacy Site row for a provider-school addition. Kept isolated
  # from ProviderSchools::Creator so the old write path can be removed in a
  # single step once the new model is switched on.
  # TODO School data remodel removal - delete when provider schools are no longer dual-written to Site.
  class LegacySiteCreator
    include ServicePattern

    DONOR_ADDRESS_LINES = %i[address2 address3 town].freeze

    def initialize(site:)
      @site = site
    end

    def call
      backfill_address1
      @site.save!
      @site
    end

  private

    def backfill_address1
      return if @site.address1.present?

      donor = DONOR_ADDRESS_LINES.find { |line| @site[line].present? }
      return if donor.nil?

      @site.address1 = @site[donor]
      @site[donor] = nil
    end
  end
end
