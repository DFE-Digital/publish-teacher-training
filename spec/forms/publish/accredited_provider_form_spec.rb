# frozen_string_literal: true

require 'rails_helper'

module Publish
  describe AccreditedProviderForm, type: :model do
    let(:user) { create(:user) }
    let(:model) { create(:provider) }

    subject { described_class.new(user, model) }

    describe 'validations' do
      it { is_expected.to validate_presence_of(:description) }
    end

    describe '#stash' do
      let(:accredited_provider) { create(:provider, :accredited_provider) }
      let(:params) do
        {
          accredited_provider_id: accredited_provider.id,
          description: 'Accredited provider description'
        }
      end

      subject { described_class.new(user, model, params:).stash }

      it { is_expected.to be_truthy }
    end

    describe '#save!' do
      let(:accredited_provider) { create(:provider, :accredited_provider) }
      let(:params) do
        {
          accredited_provider_id: accredited_provider.id,
          description: 'Accredited provider description'
        }
      end

      subject { described_class.new(user, model, params:) }

      context 'when no enrichment exists' do
        it 'correctly sets the enrichment structure' do
          expect { subject.save! }
            .to change(model, :accrediting_provider_enrichments).to(
              [an_instance_of(AccreditingProviderEnrichment)]
            )
        end
      end

      context 'when provider has existing accredited provider enrichments' do
        let(:existing_accredited_provider) { create(:provider, :accredited_provider) }
        let(:accrediting_provider_enrichments) do
          [
            { UcasProviderCode: existing_accredited_provider.provider_code, Description: 'Existing accredited provider description' }
          ]
        end

        let(:model) { create(:provider, accrediting_provider: 'N', accrediting_provider_enrichments:) }

        it 'updates the provider with the new accredited provider information' do
          subject.save!

          expect(model.accrediting_provider_enrichments.count).to eq(2)
          expect(model.accrediting_provider_enrichments.last.UcasProviderCode).to eq(accredited_provider.provider_code)
          expect(model.accrediting_provider_enrichments.last.Description).to eq('Accredited provider description')
        end
      end
    end
  end
end
