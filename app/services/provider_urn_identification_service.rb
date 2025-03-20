# frozen_string_literal: true

# Separate a list of URNs into already added, unfound and new schools
class ProviderURNIdentificationService
  attr_reader :provider, :urns

  def initialize(provider, urns = [])
    @provider = provider
    @urns = urns
  end

  def call
    existing_provider_urns = provider.sites.school.pluck(:urn).compact
    real_urns = GiasSchool.where(urn: urns).pluck(:urn)

    duplicate_urns = existing_provider_urns & real_urns
    new_urns = real_urns - existing_provider_urns
    unfound_urns = urns - real_urns

    { unfound_urns:, duplicate_urns:, new_urns: }
  end
end
