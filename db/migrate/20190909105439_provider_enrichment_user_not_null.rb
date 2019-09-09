class ProviderEnrichmentUserNotNull < ActiveRecord::Migration[5.2]
  def up
    production_user = User.find_by(email: 'tim.abell@digital.education.gov.uk')
    local_seeds_user = User.find_by(email: 'super.admin@education.gov.uk')
    local_development_user = User.first
    some_id = (production_user || local_seeds_user || local_development_user).id
    ProviderEnrichment.where(created_by_user_id: nil).each { |pe| pe.created_by_user_id = some_id; pe.save! }
    ProviderEnrichment.where(updated_by_user_id: nil).each { |pe| pe.updated_by_user_id = some_id; pe.save! }

    change_column_null :provider_enrichment, :updated_by_user_id, false
    change_column_null :provider_enrichment, :created_by_user_id, false
  end

  def down
    change_column_null :provider_enrichment, :updated_by_user_id, true
    change_column_null :provider_enrichment, :created_by_user_id, true
  end
end
