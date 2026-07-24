# frozen_string_literal: true

module ProviderSchools
  # This service determines which model should be used when creating, removing and in some instances viewing schools.
  # The legacy data model uses Site, while the new data model uses Provider::School.
  # During the rollover, both models are written to and their UUIDs may diverge, so we need a way to switch to the new data model.
  # Because Publish supports both the old and new recruitment cycles during the rollover, this switch must be based on the recruitment cycle rather than a traditional feature flag.
  class Identity
    def self.ordered_school_scope(provider:)
      new(provider:).ordered_school_scope
    end

    def initialize(provider:)
      @provider = provider
    end

    def ordered_school_scope
      if uses_provider_schools?
        provider.schools.joins(:gias_school).includes(:gias_school).order("gias_school.name")
      else
        provider.sites.order(:location_name)
      end
    end

    def school_for(uuid:)
      if uses_provider_schools?
        provider.schools.find_by!(uuid:)
      else
        provider.sites.find_by!(uuid:)
      end
    end

    def after_schools_remodel_cycle?
      provider.recruitment_cycle.after?(Settings.schools_remodel_cycle_year)
    end

    def uses_provider_schools?
      provider.recruitment_cycle.year.to_i >= Settings.schools_remodel_cycle_year.to_i
    end

  private

    attr_reader :provider
  end
end
