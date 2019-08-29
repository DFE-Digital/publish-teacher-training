class CopyEnrichmentsToNextCycle < ActiveRecord::Migration[5.2]
  def up
    next_providers = RecruitmentCycle.next_recruitment_cycle.providers.all
    rollover_service = ProviderEnrichments::RolloverEnrichmentToProviderService.new

    current_providers_with_enrichments.each do |provider|
      next if provider.enrichments.empty?

      last_enrichment = provider.enrichments.order(created_at: :desc, id: :desc).first.dup

      next_cycle_provider = next_providers.find { |n| n.provider_code == provider.provider_code }
      rollover_service.execute(enrichment: last_enrichment, new_provider: next_cycle_provider)
    end
  end

  def down
    RecruitmentCycle.next_recruitment_cycle.providers.each { |provider| provider.enrichments.destroy_all }
  end

private

  def current_providers_with_enrichments
    RecruitmentCycle.current_recruitment_cycle.providers.includes(:enrichments).all.reject { |provider| provider.enrichments.empty? }
  end
end
