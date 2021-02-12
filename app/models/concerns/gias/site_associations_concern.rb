module GIAS::SiteAssociationsConcern
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :establishments_matched_by_postcode,
                            join_table: :gias_establishment_site_postcode_matches,
                            class_name: "GIASEstablishment",
                            association_foreign_key: "establishment_id"

    has_and_belongs_to_many :establishments_matched_by_name,
                            join_table: :gias_establishment_site_name_matches,
                            class_name: "GIASEstablishment",
                            association_foreign_key: "establishment_id"
  end
end
