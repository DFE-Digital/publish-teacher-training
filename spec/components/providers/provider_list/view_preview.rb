# frozen_string_literal: true

module Providers
  module ProviderList
    class ViewPreview < ViewComponent::Preview
      def with_scitt_provider
        render(ProviderList::View.new(provider: Provider.new(id: "1", provider_name: "University A", provider_code: "AA01", provider_type: "scitt", accrediting_provider: "accredited_body", updated_at: Time.zone.now, recruitment_cycle: RecruitmentCycle.new(year: Settings.current_recruitment_cycle_year))))
      end

      def with_lead_school_provider
        render(ProviderList::View.new(provider: Provider.new(id: "1", provider_name: "University A", provider_code: "AA01", provider_type: "lead_school", accrediting_provider: "not_an_accredited_body", updated_at: Time.zone.now, recruitment_cycle: RecruitmentCycle.new(year: Settings.current_recruitment_cycle_year))))
      end

      def with_university_provider
        render(ProviderList::View.new(provider: Provider.new(id: "1", provider_name: "University A", provider_code: "AA01", provider_type: "university", accrediting_provider: "accredited_body", updated_at: Time.zone.now, recruitment_cycle: RecruitmentCycle.new(year: Settings.current_recruitment_cycle_year))))
      end
    end
  end
end
