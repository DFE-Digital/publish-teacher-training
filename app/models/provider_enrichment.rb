# == Schema Information
#
# Table name: provider_enrichment
#
#  id                 :integer          not null, primary key
#  provider_code      :text             not null
#  json_data          :jsonb
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_user_id :integer
#  last_published_at  :datetime
#  status             :integer          default("draft"), not null
#  provider_id        :integer          not null
#

class ProviderEnrichment < ApplicationRecord
  include RegionCode

  before_create :set_provider_code

  enum status: { draft: 0, published: 1 }

  belongs_to :provider,
             inverse_of: 'enrichments'
  audited associated_with: :provider

  serialize :accrediting_provider_enrichments, AccreditingProviderEnrichment::ArraySerializer

  validates_associated :accrediting_provider_enrichments

  scope :latest_created_at, -> { order(created_at: :desc) }
  scope :latest_published_at, -> { order(last_published_at: :desc) }
  scope :draft, -> { where(status: 'draft') }

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
                                         store_key: 'TrainWithDisability'],
                 accrediting_provider_enrichments: [:json,
                                                    store_key: 'AccreditingProviderEnrichments']

  validates :train_with_us, words_count: { maximum: 250 }
  validates :train_with_disability, words_count: { maximum: 250 }

  validates :email, :website, :telephone,
            :address1, :address3, :address4,
            :postcode, :train_with_us, :train_with_disability,
            presence: true, on: :publish

  def has_been_published_before?
    last_published_at.present?
  end

  def publish(current_user)
    update(status: 'published', last_published_at: Time.now.utc, updated_by_user_id: current_user.id)
  end

  def accrediting_provider_enrichment(provider_code)
    accrediting_provider_enrichments&.find do |enrichment|
      enrichment.UcasProviderCode == provider_code
    end
  end

private

  def set_provider_code
    # Note: provider_code is only here to support c# counterpart, until provide_code is removed from database
    self.provider_code = provider.provider_code if provider_code.blank?
  end
end
