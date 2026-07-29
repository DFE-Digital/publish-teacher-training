# frozen_string_literal: true

# Builds the Provider::School rows that production always has alongside a
# provider's legacy sites, created either by the dual-write in
# Publish::Providers::Schools::ChecksController or by
# DataHub::SchoolsBackfill::Executor.
#
# Both copy site.uuid onto provider_school.uuid, and the course school pickers
# rely on that pairing to resolve the uuid they post back to a SiteStatus. A
# fixture that creates provider_schools without it is not representative — the
# schools silently fail to resolve.
module SchoolPairingHelper
  # Mirrors every kept school site the provider has. Idempotent, so it is safe
  # to call again after adding more sites.
  def pair_provider_schools_with_sites(provider)
    unpaired = provider.sites.reload.select(&:school?).reject do |site|
      Provider::School.exists?(provider:, uuid: site.uuid)
    end

    unpaired.map do |site|
      gias_school = GiasSchool.find_by(urn: site.urn) || create(:gias_school, urn: site.urn, name: site.location_name)

      create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid)
    end
  end

  # A matched site and Provider::School for a provider that has neither yet.
  def create_paired_school(provider:, name:, site_code:, **site_attributes)
    uuid = SecureRandom.uuid
    gias_school = create(:gias_school, name:)
    site = create(
      :site,
      provider:,
      uuid:,
      code: site_code,
      urn: gias_school.urn,
      location_name: name,
      **site_attributes,
    )
    provider_school = create(:provider_school, provider:, gias_school:, site_code:, uuid:)

    [site, provider_school]
  end
end

RSpec.configure do |config|
  config.include SchoolPairingHelper
end
