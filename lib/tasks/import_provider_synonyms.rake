# frozen_string_literal: true

require 'csv'

desc 'import provider synonyms with csv data'
task import_provider_synonyms_with_csv_data: :environment do
  csv_filepath = Rails.root.join('csv/provider_synonyms_data.csv')
  CSV.foreach(csv_filepath, headers: true) do |row|
    provider_details = row.to_h.symbolize_keys

    provider_code = provider_details[:provider_code]
    synonyms = JSON.parse(provider_details[:synonyms])

    RecruitmentCycle.current_recruitment_cycle.providers.find_by(provider_code:).update(synonyms:)
  end
end
