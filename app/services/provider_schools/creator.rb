# frozen_string_literal: true

# Writes a Provider::School row against the new GIAS-backed data model.
# Swallows RecordNotUnique so a re-run (e.g. race with the schools backfill
# executor) is a no-op, matching the backfill's ON CONFLICT DO NOTHING.
module ProviderSchools
  class Creator
    include ServicePattern

    def initialize(provider:, gias_school_id:, site_code:)
      @provider = provider
      @gias_school_id = gias_school_id
      @site_code = site_code
    end

    def call
      @provider.schools.find_or_create_by!(gias_school_id: @gias_school_id, site_code: @site_code)
    rescue ActiveRecord::RecordNotUnique
      @provider.schools.find_by!(gias_school_id: @gias_school_id, site_code: @site_code)
    end
  end
end
