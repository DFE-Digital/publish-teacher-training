class CleanUpAccreditingProviderData < ActiveRecord::Migration[6.0]
  def change
    rc = RecruitmentCycle.current
    providers = rc.providers
    current_accrediting_providers = providers.accredited_body
    current_accrediting_provider_codes = current_accrediting_providers.map(&:provider_code)
    current_cycles_accrediting_provider_codes = rc.courses.map(&:accrediting_provider_code).uniq.compact
    incorrectly_marked_providers = current_accrediting_provider_codes - current_cycles_accrediting_provider_codes
    incorrectly_marked_providers.each do |provider_code|
      provider = Provider.find_by!(provider_code: provider_code)
      provider.update(accrediting_provider: "N")
    end
  end
end
