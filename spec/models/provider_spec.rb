# == Schema Information
#
# Table name: provider
#
#  id            :integer          not null, primary key
#  address4      :text
#  provider_name :text
#  scheme_member :text
#  contact_name  :text
#  year_code     :text
#  provider_code :text
#  provider_type :text
#  postcode      :text
#  scitt         :text
#  url           :text
#  address1      :text
#  address2      :text
#  address3      :text
#  email         :text
#  telephone     :text
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
end
