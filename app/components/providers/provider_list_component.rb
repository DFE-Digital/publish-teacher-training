module Providers
  class ProviderListComponent < GovukComponent::Base
    include Support::TimeHelper

    def initialize(provider)
      @provider = provider
    end

    def formatted_provider_type
      case @provider.provider_type
      when "scitt" then "SCITT"
      when "lead_school" then "Lead school"
      when "university" then "University"
      end
    end

    def formatted_accrediting_provider
      @provider.accredited_body? ? "Yes" : "No"
    end
  end
end
