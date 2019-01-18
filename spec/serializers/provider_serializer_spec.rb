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

require "rails_helper"

RSpec.describe ProviderSerializer do
  let(:provider) { create :provider }
  subject { serialize(provider) }

  it { should include(institution_code: provider.provider_code) }
  it { should include(institution_name: provider.provider_name) }
  it { should include(address1: provider.enrichments.last.address1) }
  it { should include(address2: provider.enrichments.last.address2) }
  it { should include(address3: provider.enrichments.last.address3) }
  it { should include(address4: provider.enrichments.last.address4) }
  it { should include(postcode: provider.enrichments.last.postcode) }
  it { should include(institution_type: provider.provider_type) }
  it { should include(accrediting_provider: nil) }

  describe 'ProviderSerializer#region_code' do
    subject do
      serialize(provider)["region_code"]
    end

    describe "provider region code 'London' can be overriden by enrichment region code 'Scotland'" do
      let(:enrichment) do
        build(:provider_enrichment, region_code: "Scotland")
      end

      let(:provider) { create :provider, region_code: "London", enrichments: [enrichment] }
      it { is_expected.not_to eql(format("%02d", 1)) }
      it { is_expected.to eql(format("%02d", 11)) }
      it { expect(subject.length).to eql(2) }
    end

    describe "provider region code 00 is overriden with enrichment region code" do
      let(:enrichment) do
        build(:provider_enrichment, region_code: region_code)
      end
      let(:region_code) { 1 }
      let(:provider) { create :provider, region_code: 0, enrichments: [enrichment] }
      it { is_expected.to eql(format("%02d", region_code)) }
      it { is_expected.not_to eql(format("%02d", 0)) }
    end
  end
end
