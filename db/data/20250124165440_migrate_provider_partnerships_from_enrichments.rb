# frozen_string_literal: true

class MigrateProviderPartnershipsFromEnrichments < ActiveRecord::Migration[8.0]
  def up
    Provider.where.not(accrediting_provider_enrichments: nil).find_each do |training_provider|
      training_provider.accrediting_provider_enrichments.each do |enrichment|
        accredited_provider = Provider.find_by(recruitment_cycle_id: training_provider.recruitment_cycle_id, provider_code: enrichment.UcasProviderCode)

        created = training_provider.accredited_partnerships.create(accredited_provider:, description: enrichment.Description)
        Rails.logger.warn("Partnership could not be created #{training_provider.recruitment_cycle_id}:#{accredited_provider.id}:#{training_provider.id}") unless created
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
