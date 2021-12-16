module Providers
  class ProviderListComponent < GovukComponent::Base
    include Support::TimeHelper

    PROVIDER_TYPE_LOOKUP = {
      "scitt" => "SCITT",
      "lead_school" => "Lead school",
      "university" => "University",
    }.freeze

    def initialize(provider:)
      super(classes: classes, html_attributes: html_attributes)
      @provider = provider
    end

    def formatted_provider_type
      PROVIDER_TYPE_LOOKUP[@provider.provider_type]
    end

    def formatted_accrediting_provider
      @provider.accredited_body? ? "Yes" : "No"
    end
  end
end
