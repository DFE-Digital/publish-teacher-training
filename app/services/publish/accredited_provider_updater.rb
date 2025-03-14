# frozen_string_literal: true

################################################################
# WARNING:
#
# This service is only to be used when moving ALL a providers accredited
# courses to the accredited provider.
################################################################
module Publish
  class AccreditedProviderUpdater
    attr_reader :provider, :new_accredited_provider, :recruitment_cycle

    def initialize(provider_code:, recruitment_cycle_year:, new_accredited_provider_code:)
      @recruitment_cycle = RecruitmentCycle.find_by!(year: recruitment_cycle_year)
      @provider = Provider.find_by!(provider_code:, recruitment_cycle: @recruitment_cycle)
      @new_accredited_provider = Provider.find_by!(provider_code: new_accredited_provider_code, recruitment_cycle: @recruitment_cycle)
    end

    def update_provider_and_courses
      ActiveRecord::Base.transaction do
        update_provider
        update_courses
      end
    end

    def update_provider
      provider.update!(accredited: false,
                       accrediting_provider_enrichments: new_accrediting_provider_enrichments)
    end

    def update_courses
      courses = provider.courses
      courses.each { |c| c.update!(accredited_provider_code: new_accredited_provider.provider_code) }
    end

    private

    def new_accrediting_provider_enrichments
      existing_accrediting_provider_enrichments = provider.accrediting_provider_enrichments || []

      return existing_accrediting_provider_enrichments if new_accredited_provider_code_in_enrichments?(
        existing_accrediting_provider_enrichments
      )

      accredited_provider_enrichment = AccreditingProviderEnrichment.new(
        {
          UcasProviderCode: new_accredited_provider.provider_code,
          Description: ''
        }
      )

      existing_accrediting_provider_enrichments << accredited_provider_enrichment
    end

    def new_accredited_provider_code_in_enrichments?(accrediting_provider_enrichments)
      ucas_provider_code = new_accredited_provider.provider_code
      accrediting_provider_enrichments.map(&:UcasProviderCode).include?(ucas_provider_code)
    end
  end
end
