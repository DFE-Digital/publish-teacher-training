# == Schema Information
#
# Table name: provider_enrichment
#
#  id                 :integer          not null, primary key
#  provider_code      :text             not null
#  json_data          :jsonb
#  updated_by_user_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_user_id :integer          not null
#  last_published_at  :datetime
#  status             :integer          default("draft"), not null
#  provider_id        :integer          not null
#

class ProviderEnrichment < ApplicationRecord
  include RegionCode

  before_save :ensure_region_code_is_an_integer_in_json_data
  before_create :set_provider_code

  enum status: { draft: 0, published: 1, rolled_over: 2 }

  belongs_to :provider,
             inverse_of: 'enrichments'

  audited except: :json_data,
          associated_with: :provider

  serialize :accrediting_provider_enrichments, AccreditingProviderEnrichment::ArraySerializer

  validates_associated :accrediting_provider_enrichments

  scope :latest_created_at, -> { order(created_at: :desc) }
  scope :latest_published_at, -> { order(last_published_at: :desc) }
  scope :draft, -> { where(status: %w[draft rolled_over]) }

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

  validates :train_with_us, words_count: { maximum: 250, message: "^Reduce the word count for training with you" }
  validates :train_with_disability, words_count: { maximum: 250, message: "^Reduce the word count for training with disabilities and other needs" }

  validates :email, email: true, on: :update, allow_nil: true
  validates :email, email: true, on: :publish

  validates :telephone, phone: { message: '^Enter a valid telephone number' }, allow_nil: true

  validates :website, :telephone,
            :address1, :address3, :address4,
            :postcode, :train_with_us, :train_with_disability,
            presence: true, on: :publish

  def draft?
    status.in? %w[draft rolled_over]
  end

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

  def ensure_region_code_is_an_integer_in_json_data
    return if json_data['RegionCode'].blank?
    return if json_data['RegionCode'].is_a?(Integer)

    json_data['RegionCode'] = ProviderEnrichment.region_codes[json_data['RegionCode']]
  end

  def set_provider_code
    # Note: provider_code is only here to support c# counterpart, until provide_code is removed from database
    self.provider_code = provider.provider_code if provider_code.blank?
  end
end
