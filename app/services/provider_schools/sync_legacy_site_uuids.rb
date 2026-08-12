# frozen_string_literal: true

module ProviderSchools
  # Keeps Provider::School UUIDs aligned with their copied legacy Site rows during
  # rollover, while course school updates still dual-write to SiteStatus.
  # TODO School data remodel removal - delete when Provider::School UUIDs no longer map to legacy Sites.
  class SyncLegacySiteUuids
    include ServicePattern

    class LegacySiteMismatchError < StandardError; end

    def initialize(provider:)
      @provider = provider
    end

    def call
      provider_schools.find_each do |provider_school|
        legacy_site_uuid = legacy_site_uuid_for(provider_school)
        next if provider_school.uuid == legacy_site_uuid

        provider_school.update_columns(uuid: legacy_site_uuid)
      end
    end

  private

    attr_reader :provider

    def provider_schools
      Provider::School.where(provider:).includes(:gias_school)
    end

    def legacy_site_uuid_for(provider_school)
      legacy_site_uuids = legacy_site_uuids_by_identity.fetch(identity_for(provider_school), [])
      return legacy_site_uuids.first if legacy_site_uuids.one?

      raise LegacySiteMismatchError, mismatch_message(provider_school, legacy_site_uuids)
    end

    def legacy_site_uuids_by_identity
      @legacy_site_uuids_by_identity ||= Site.school.kept.where(provider:)
        .pluck(:urn, :code, :uuid)
        .each_with_object({}) do |(urn, code, uuid), index|
          (index[[urn, code]] ||= []) << uuid
        end
    end

    def identity_for(provider_school)
      [provider_school.gias_school.urn, provider_school.site_code]
    end

    def mismatch_message(provider_school, legacy_site_uuids)
      count = legacy_site_uuids.size
      "expected one legacy site for provider=#{provider.id} " \
        "provider_school=#{provider_school.id} " \
        "site_code=#{provider_school.site_code} " \
        "urn=#{provider_school.gias_school.urn.inspect}, found #{count}"
    end
  end
end
