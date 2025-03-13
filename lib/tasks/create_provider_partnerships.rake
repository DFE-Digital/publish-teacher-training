# frozen_string_literal: true

namespace :provider_partnerships do
  task create_from_enrichments: :environment do
    count = 0
    Provider.where.not(accrediting_provider_enrichments: nil).find_each do |training_provider|
      training_provider.accrediting_provider_enrichments.each do |enrichment|
        accredited_provider = Provider.find_by(recruitment_cycle_id: training_provider.recruitment_cycle_id, provider_code: enrichment.UcasProviderCode)

        created = training_provider.accredited_partnerships.create(accredited_provider:, description: enrichment.Description)
        count += 1 if created.persisted?
      end
    end

    puts "#{count} partnerships created!"
  end
end
