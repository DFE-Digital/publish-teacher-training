# frozen_string_literal: true

module Publish
  class AccreditedProviderUpdater
    attr_reader :provider, :new_accredited_provider, :recruitment_cycle

    def initialize(provider_code:, recruitment_cycle_year:, new_accredited_provider_code:)
      @recruitment_cycle = RecruitmentCycle.find_by!(year: recruitment_cycle_year)
      @provider = Provider.find_by!(provider_code:, recruitment_cycle: @recruitment_cycle)
      @new_accredited_provider = Provider.find_by!(provider_code: new_accredited_provider_code, recruitment_cycle: @recruitment_cycle)
    end

    def update_provider_and_courses
      update_provider && update_courses
    end

    def update_provider
      accredited_provider_enrichment = AccreditingProviderEnrichment.new(
        {
          UcasProviderCode: new_accredited_provider.provider_code,
          Description: ''
        }
      )
      accrediting_provider_enrichments = provider.accrediting_provider_enrichments || []
      accrediting_provider_enrichments << accredited_provider_enrichment

      provider.update!(accrediting_provider: 'not_an_accredited_provider',
                       accrediting_provider_enrichments:)
    end

    def update_courses
      courses = provider.courses
      courses.update_all(accredited_provider_code: new_accredited_provider.provider_code)
    end
  end
end
