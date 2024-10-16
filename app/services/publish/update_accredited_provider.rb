# frozen_string_literal: true

module Publish
  class UpdateAccreditedProvider
    attr_reader :from_provider, :to_provider, :recruitment_cycle

    def initialize(from_provider_code:, recruitment_cycle_year:, to_provider_code:)
      @recruitment_cycle = RecruitmentCycle.find_by!(year: recruitment_cycle_year)
      @from_provider = Provider.find_by!(provider_code: from_provider_code, recruitment_cycle: @recruitment_cycle)
      @to_provider = Provider.find_by!(provider_code: to_provider_code, recruitment_cycle: @recruitment_cycle)
    end

    def update_provider_and_courses
      update_provider && update_courses
    end

    def update_provider
      from_provider.update_columns(accrediting_provider: 'not_an_accredited_provider',
                                   accrediting_provider_enrichments: new_accrediting_provider_enrichments)
    end

    def update_courses
      courses = from_provider.courses
      courses.update_all(accredited_provider_code: to_provider.provider_code)
    end

    private

    def new_accrediting_provider_enrichments
      existing_accrediting_provider_enrichments = from_provider.accrediting_provider_enrichments || []

      return existing_accrediting_provider_enrichments if new_accredited_provider_code_in_enrichments?(
        existing_accrediting_provider_enrichments
      )

      accredited_provider_enrichment = AccreditingProviderEnrichment.new(
        {
          UcasProviderCode: to_provider.provider_code,
          Description: ''
        }
      )

      existing_accrediting_provider_enrichments << accredited_provider_enrichment
    end

    def new_accredited_provider_code_in_enrichments?(accrediting_provider_enrichments)
      ucas_provider_code = to_provider.provider_code
      accrediting_provider_enrichments.map(&:UcasProviderCode).include?(ucas_provider_code)
    end
  end
end
