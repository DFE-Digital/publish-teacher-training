module GIAS::ProviderAssociationsConcern
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :establishments_matched_by_postcode,
                            join_table: :gias_establishment_provider_postcode_matches,
                            class_name: "GIASEstablishment",
                            association_foreign_key: "establishment_id"

    has_and_belongs_to_many :establishments_matched_by_name,
                            join_table: :gias_establishment_provider_name_matches,
                            class_name: "GIASEstablishment",
                            association_foreign_key: "establishment_id"

    scope :that_match_establishments_by_postcode,
          -> do
            joins(:establishments_matched_by_postcode).distinct
          end

    scope :with_sites_that_match_establishments_by_postcode,
          -> do
            joins(sites: [:establishments_matched_by_postcode]).distinct
          end

    scope :with_establishments_that_match_any_postcode,
          -> do
            where(id: (that_match_establishments_by_postcode.pluck(:id) +
                       with_sites_that_match_establishments_by_postcode.pluck(:id)))
          end

    scope :that_match_establishments_by_name,
          -> do
            joins(:establishments_matched_by_name).distinct
          end

    scope :with_sites_that_match_establishments_by_name,
          -> do
            joins(sites: [:establishments_matched_by_name]).distinct
          end

    scope :with_establishments_that_match_any_name,
          -> do
            where(id: (that_match_establishments_by_name.reorder(:id).pluck(:id) +
                       with_sites_that_match_establishments_by_name.reorder(:id).pluck(:id)))
          end

    scope :that_match_establishments_by_name_and_postcode,
          -> do
            joins(:establishments_matched_by_postcode)
              .joins(:establishments_matched_by_name)
              .where('"gias_establishment_provider_postcode_matches"."establishment_id" = "gias_establishment_provider_name_matches"."establishment_id"')
          end

    scope :with_sites_that_match_establishments_by_name_and_postcode,
          -> do
            joins(sites: [:establishments_matched_by_postcode])
              .joins(sites: [:establishments_matched_by_name])
              .where('"gias_establishment_site_postcode_matches"."establishment_id" = "gias_establishment_site_name_matches"."establishment_id"')
          end

    def sites_with_establishments_matched_by_postcode
      sites.joins(:establishments_matched_by_postcode)
    end

    def sites_with_establishments_matched_by_name
      sites.joins(:establishments_matched_by_name)
    end
  end
end
