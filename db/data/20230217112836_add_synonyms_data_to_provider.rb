# frozen_string_literal: true

class AddSynonymsDataToProvider < ActiveRecord::Migration[7.0]
  def up
    csv_filepath = Rails.root.join(__FILE__.gsub('.rb', '.csv'))
    CSV.foreach(csv_filepath, headers: true) do |row|
      provider_details = row.to_h.symbolize_keys

      provider_code = provider_details[:provider_code]
      synonyms = JSON.parse(provider_details[:synonyms])

      RecruitmentCycle.current_recruitment_cycle.providers.find_by(provider_code:).update(synonyms:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
