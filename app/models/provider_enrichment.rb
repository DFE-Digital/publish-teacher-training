# == Schema Information
#
# Table name: provider_enrichment
#
#  id                 :integer          not null
#  provider_code      :text             not null, primary key
#  json_data          :jsonb
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_user_id :integer
#  last_published_at  :datetime
#  status             :integer          default("draft"), not null
#

class ProviderEnrichment < ApplicationRecord
  self.primary_key = "provider_code"

  include RegionCode

  enum status: { draft: 0, published: 1 }

  belongs_to :provider, foreign_key: :provider_code, primary_key: :provider_code

  scope :latest_created_at, -> { order(created_at: :desc) }

  jsonb_accessor :json_data,
                 email: [:string, store_key: 'Email'],
                 website: [:string, store_key: 'Website'],
                 address1: [:string, store_key: 'Address1'],
                 address2: [:string, store_key: 'Address2'],
                 address3: [:string, store_key: 'Address3'],
                 address4: [:string, store_key: 'Address4'],
                 postcode: [:string, store_key: 'Postcode'],
                 region_code: [:integer, store_key: 'RegionCode'],
                 telephone: [:string, store_key: 'Telephone'],
                 train_with_us: [:string, store_key: 'TrainWithUs'],
                 train_with_disability: [:string,
                                         store_key: 'TrainWithDisability']
end
