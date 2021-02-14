class GIASEstablishment < ApplicationRecord
  has_and_belongs_to_many :providers,
                          join_table: :gias_establishment_provider_postcode_matches,
                          foreign_key: "establishment_id",
                          inverse_of: :establishments

  has_and_belongs_to_many :providers_matched_by_postcode,
                          join_table: :gias_establishment_provider_postcode_matches,
                          class_name: "Provider",
                          foreign_key: "establishment_id"

  has_and_belongs_to_many :sites_matched_by_postcode,
                          join_table: :gias_establishment_site_postcode_matches,
                          class_name: "Site",
                          foreign_key: "establishment_id"

  has_and_belongs_to_many :providers_matched_by_name,
                          join_table: :gias_establishment_provider_name_matches,
                          class_name: "Provider",
                          foreign_key: "establishment_id"

  has_and_belongs_to_many :sites_matched_by_name,
                          join_table: :gias_establishment_site_name_matches,
                          class_name: "Site",
                          foreign_key: "establishment_id"

  scope :that_match_providers_by_postcode, -> do
    joins(:providers_matched_by_postcode).distinct
  end

  scope :that_match_sites_by_postcode, -> do
    joins(:sites_matched_by_postcode).distinct
  end

  scope :that_match_providers_or_sites_by_postcode, -> do
    where(id: (that_match_providers_by_postcode.pluck(:id) + that_match_sites_by_postcode.pluck(:id))).distinct
  end

  scope :that_match_providers_by_name, -> do
    joins(:providers_matched_by_name).distinct
  end

  scope :that_match_sites_by_name, -> do
    joins(:sites_matched_by_name).distinct
  end

  scope :that_match_providers_or_sites_by_name, -> do
    where(id: (that_match_providers_by_name.pluck(:id) + that_match_sites_by_name.pluck(:id)))
  end
end
