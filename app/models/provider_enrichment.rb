class ProviderEnrichment < ApplicationRecord
  self.table_name = "provider_enrichment"
  self.primary_key = "provider_code"

  enum status: { draft: 0, published: 1 }

  belongs_to :provider, foreign_key: :provider_code, primary_key: :provider_code

  scope :with_address_info,
        -> { where("json_data ?| array['Address1', 'Address2', 'Address3', 'Address4', 'Postcode']") }

  jsonb_accessor :json_data,
                 email: [:string, store_key: 'Email'],
                 website: [:string, store_key: 'Website'],
                 address1: [:string, store_key: 'Address1'],
                 address2: [:string, store_key: 'Address2'],
                 address3: [:string, store_key: 'Address3'],
                 address4: [:string, store_key: 'Address4'],
                 postcode: [:string, store_key: 'Postcode'],
                 telephone: [:string, store_key: 'Telephone'],
                 train_with_us: [:string, store_key: 'TrainWithUs'],
                 train_with_disability: [:string,
                                         store_key: 'TrainWithDisability']
end
