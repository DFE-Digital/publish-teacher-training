# frozen_string_literal: true

module Publish
  class AccreditedProviderForm < Form
    delegate :provider_name, to: :accredited_provider

    FIELDS = %i[
      description
      accredited_provider_id
    ].freeze

    attr_accessor(*FIELDS)

    validates :description, presence: true

    alias compute_fields new_attributes

    def accredited_provider
      @accredited_provider ||= RecruitmentCycle.current.providers.find(accredited_provider_id)
    end

    private

    def assign_attributes_to_model
      model.accrediting_provider_enrichments = [] if model.accrediting_provider_enrichments.nil?

      model.accrediting_provider_enrichments << enrichment_params
    end

    def enrichment_params
      AccreditingProviderEnrichment.new(
        {
          UcasProviderCode: accredited_provider.provider_code,
          Description: description
        }
      )
    end
  end
end
