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
    let!(:old_provider) { create(:provider, age: 1.hour.ago) }
    let!(:provider)     { create(:provider, age: 1.hour.ago) }

    context 'with a provider whose updated_at has been changed in the past' do
      before  { provider.touch }
      subject { Provider.changed_since(10.minutes.ago) }

      it { should_not include old_provider }
      it { should     include provider }

      describe 'when the checked timestamp matches the provider updated_at' do
        subject { Provider.changed_since(provider.updated_at) }

        it { should include provider }
      end
    end

    context 'with a provider enrichment that has published changes' do
      before do
        provider.enrichments.first.update(
          status: :published,
          updated_at: DateTime.now
        )
      end

      subject { Provider.changed_since(10.minutes.ago) }

      it { should_not include old_provider }
      it { should     include provider }

      describe 'when the checked timestamp matches the enrichment updated_at' do
        subject { Provider.changed_since(provider.enrichments.first.updated_at) }

        it { should include provider }
      end
    end

    context 'with an old provider that has a new draft enrichment' do
      before do
        provider.enrichments.first.update(
          status: :draft,
          updated_at: DateTime.now
        )
      end

      subject { Provider.changed_since(10.minutes.ago) }

      it { should_not include provider }
    end

    context 'with a provider whose site has been updated' do
      before  { provider.sites.first.touch }
      subject { Provider.changed_since(10.minutes.ago) }

      it { should_not include old_provider }
      it { should     include provider }

      describe "when the checked timestamp matches the site updated_at" do
        subject { Provider.changed_since(provider.sites.first.updated_at) }

        it { should include provider }
      end
    end
  end
end
