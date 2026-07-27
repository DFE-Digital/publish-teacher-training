# frozen_string_literal: true

module ProviderSchools
  # Resolves schools for listing and detail views from the new Provider::School model.
  # Write/removal paths may still use after_schools_remodel_cycle? where dual-writing
  # to legacy Site records continues during the remodel transition.
  class Identity
    def self.ordered_school_scope(provider:)
      new(provider:).ordered_school_scope
    end

    def initialize(provider:)
      @provider = provider
    end

    def ordered_school_scope
      provider.schools.joins(:gias_school).includes(:gias_school).order("gias_school.name")
    end

    def school_for(uuid:)
      provider.schools.find_by!(uuid:)
    end

    def after_schools_remodel_cycle?
      provider.recruitment_cycle.after?(Settings.schools_remodel_cycle_year)
    end

  private

    attr_reader :provider
  end
end
