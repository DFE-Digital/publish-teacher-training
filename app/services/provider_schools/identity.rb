# frozen_string_literal: true

module ProviderSchools
  class Identity
    def self.uuid_for(site:)
      new(provider: site.provider).uuid_for(site:)
    end

    def self.visible_sites(provider:)
      new(provider:).visible_sites
    end

    def initialize(provider:)
      @provider = provider
    end

    def uuid_for(site:)
      schools_remodel_cycle? ? provider_school_for(site:).uuid : site.uuid
    end

    def visible_sites
      return provider.sites unless schools_remodel_cycle?

      provider
        .sites
        .joins("INNER JOIN gias_school ON gias_school.urn = site.urn")
        .joins(
          "INNER JOIN provider_school ON provider_school.provider_id = site.provider_id " \
          "AND provider_school.gias_school_id = gias_school.id " \
          "AND provider_school.site_code = site.code",
        )
    end

    def site_for(uuid:)
      if schools_remodel_cycle?
        site_for_provider_school(provider_school: provider_school_for(uuid:))
      else
        provider.sites.find_by!(uuid:)
      end
    end

    def provider_school_for(site: nil, uuid: nil)
      return provider.schools.find_by!(uuid:) if uuid.present?

      provider
        .schools
        .joins(:gias_school)
        .find_by!(gias_school: { urn: site.urn }, site_code: site.code)
    end

    def schools_remodel_cycle?
      provider.recruitment_cycle.after?(Settings.schools_remodel_cycle_year)
    end

  private

    attr_reader :provider

    def site_for_provider_school(provider_school:)
      provider.sites.find_by!(urn: provider_school.gias_school.urn, code: provider_school.site_code)
    end
  end
end
