# == Schema Information
#
# Table name: provider
#
#  id                   :integer          not null, primary key
#  address4             :text
#  provider_name        :text
#  scheme_member        :text
#  contact_name         :text
#  year_code            :text
#  provider_code        :text
#  provider_type        :text
#  postcode             :text
#  scitt                :text
#  url                  :text
#  address1             :text
#  address2             :text
#  address3             :text
#  email                :text
#  telephone            :text
#  region_code          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  accrediting_provider :text
#

require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject { create(:provider) }

  describe 'associations' do
    it { should have_many(:sites) }
  end

  describe '#address_info' do
    it 'returns address of the provider' do
      provider = create(:provider, enrichments: [])
      expect(provider.address_info).to eq(
        'address1' => provider.address1,
        'address2' => provider.address2,
        'address3' => provider.address3,
        'address4' => provider.address4,
        'postcode' => provider.postcode,
        'region_code' => provider.region_code
      )
    end

    context 'provider has enrichments' do
      it 'returns json_data from the last enrichment' do
        enrichment = build(:provider_enrichment)
        provider = create(:provider, enrichments: [enrichment])

        expect(provider.address_info).to eq(
          'address1' => enrichment.address1,
          'address2' => enrichment.address2,
          'address3' => enrichment.address3,
          'address4' => enrichment.address4,
          'postcode' => enrichment.postcode,
          'region_code' => enrichment.region_code
        )
      end
    end
  end

  describe '#changed_since' do
    context 'with a provider whose updated_at has changed since' do
      let(:site) do
        build(:site,
              updated_at: 1.hour.ago,
              provider: nil)
      end
      let!(:old_provider) do
        create(:provider,
               updated_at: 1.hour.ago,
               created_at: 1.hour.ago,
               sites: [site])
      end
      let(:update_time) { 5.minutes.ago }
      let!(:updated_provider) { create(:provider, updated_at: update_time) }

      it 'does not includes providers updated before the given time' do
        expect(Provider.changed_since(10.minutes.ago))
          .not_to include old_provider
      end

      it 'includes providers whose records have been updated since the given time' do
        expect(Provider.changed_since(10.minutes.ago))
          .to include updated_provider
      end

      it 'includes providers updated precisely at the given time' do
        expect(Provider.changed_since(update_time)).to include updated_provider
      end
    end

    context 'with a provider enrichment that has been updated' do
      let!(:provider) do
        create(:provider,
               updated_at: 1.hour.ago,
               created_at: 1.hour.ago)
      end

      it 'includes the provider' do
        provider.enrichments.first.touch
        expect(Provider.changed_since(10.minutes.ago)).to include provider
      end
    end

    context 'with a provider whose site has been updated' do
      let(:site) do
        build(:site,
              updated_at: 5.minutes.ago,
              provider: nil)
      end
      let!(:provider) do
        create(:provider,
               updated_at: 1.hour.ago,
               created_at: 1.hour.ago,
               sites: [site])
      end

      it 'includes providers whose sites have been updated' do
        provider.sites.first.touch
        expect(Provider.changed_since(10.minutes.ago)).to include provider
      end
    end
  end
end
