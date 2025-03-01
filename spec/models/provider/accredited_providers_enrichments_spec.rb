# frozen_string_literal: true

require 'rails_helper'

describe Provider do
  subject do
    provider.accredited_bodies
  end

  before do
    allow(Settings.features).to receive(:provider_partnerships).and_return(false)
    provider.reload
  end

  let(:accrediting_provider_enrichments) { [] }
  let(:description) { 'Ye olde establishmente' }
  let(:courses) { [] }
  let(:provider) do
    create(:provider,
           provider_name: 'ACME SCITT',
           provider_code: 'A01',
           accrediting_provider_enrichments:,
           courses:)
  end

  context 'with no accrediting provider (via courses)' do
    it { is_expected.to be_empty }

    context 'with an old accredited provider enrichment' do
      let(:accrediting_provider_enrichments) do
        [{
          'Description' => description,
          # XX4 might have previously been an accrediting provider for this provider, and the data is still in the database
          'UcasProviderCode' => 'XX4'
        }]
      end

      it { is_expected.to be_empty }
    end
  end

  context 'with an accrediting provider (via courses)' do
    let(:accrediting_provider) { build(:provider, provider_code: 'AP1') }
    let(:courses) { [build(:course, course_code: 'P33P', accrediting_provider:)] }
    let(:accredited_provider) { accrediting_provider }

    let(:accrediting_provider_enrichments) do
      [{ UcasProviderCode: accredited_provider.provider_code }]
    end

    its(:length) { is_expected.to be(1) }

    describe 'the returned accredited provider' do
      subject { provider.accredited_bodies.first }

      its([:description]) { is_expected.to eq('') }
      its([:provider_code]) { is_expected.to eq(accrediting_provider.provider_code) }
      its([:provider_name]) { is_expected.to eq(accrediting_provider.provider_name) }
    end

    context 'with an accredited provider enrichment' do
      let(:accrediting_provider_enrichments) do
        [{
          'Description' => description,
          'UcasProviderCode' => accrediting_provider.provider_code
        }]
      end

      its(:length) { is_expected.to be(1) }

      describe 'the returned accredited provider' do
        subject { provider.accredited_bodies.first }

        its([:description]) { is_expected.to eq(description) }
        its([:provider_code]) { is_expected.to eq(accrediting_provider.provider_code) }
        its([:provider_name]) { is_expected.to eq(accrediting_provider.provider_name) }
      end
    end

    context 'with a corrupt accredited provider enrichment' do
      let(:accrediting_provider_enrichments) do
        [{
          'Description' => description
          # UcasProviderCode missing. We found data like this in our database so need to handle it.
        }]
      end

      its(:length) { is_expected.to be(0) }
    end
  end
end
