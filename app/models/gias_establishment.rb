class GIASEstablishment < ApplicationRecord
  has_and_belongs_to_many :providers,
                          join_table: :gias_establishment_provider_postcode_matches,
                          foreign_key: "establishment_id",
                          inverse_of: :establishments

end
