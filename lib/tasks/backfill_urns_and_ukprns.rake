require "csv"

desc "Backfill Providers URNs and UKPRNs"
task backfill_providers_with_urn_and_ukprn: :environment do
  CSV.foreach(Rails.root.join("csv/providers_with_urn_and_ukprn.csv"), headers: true) do |row|
    provider = RecruitmentCycle.current_recruitment_cycle.providers.find_by(provider_code: row["provider_code"])
    provider&.update(ukprn: row["ukprn"], urn: row["urn"])
  end
end

desc "Backfill provider sites with URNs"
task backfill_provider_sites_with_urn: :environment do
  current_recruitment_cycle_providers_ids = RecruitmentCycle.current_recruitment_cycle.providers.pluck(:id)
  CSV.foreach(Rails.root.join("csv/provider_sites_with_urn.csv"), headers: true) do |row|
    site = Site.where(provider_id: current_recruitment_cycle_providers_ids).find_by(code: row["site_code"])
    site&.update(urn: row["establishment_urn"])
  end
end
