# frozen_string_literal: true

module ProviderSchools
  class Identity
    def self.ordered_school_scope(provider:)
      new(provider:).ordered_school_scope
    end

    def initialize(provider:)
      @provider = provider
    end

    def ordered_school_scope
      if after_schools_remodel_cycle?
        provider.schools.joins(:gias_school).includes(:gias_school).order("gias_school.name")
      else
        provider.sites.order(:location_name)
      end
    end

    def school_for(uuid:)
      after_schools_remodel_cycle? ? provider.schools.find_by!(uuid:) : provider.sites.find_by!(uuid:)
    end

    def provider_school_for(site:)
      provider
        .schools
        .joins(:gias_school)
        .find_by!(gias_school: { urn: site.urn }, site_code: site.code)
    end

    def after_schools_remodel_cycle?
      provider.recruitment_cycle.after?(Settings.schools_remodel_cycle_year)
    end

  private

    attr_reader :provider
  end
end
