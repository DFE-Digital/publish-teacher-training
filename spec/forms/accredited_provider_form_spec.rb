# frozen_string_literal: true

require 'rails_helper'

describe AccreditedProviderForm, type: :model do
  subject { described_class.new(user, model) }

  let(:user) { create(:user) }
  let(:model) { create(:provider) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:description) }

    context 'word count' do
      before do
        subject.description = Faker::Lorem.sentence(word_count: 251)
        subject.valid?
      end

      it 'validates the word count for the description' do
        expect(subject).not_to be_valid
        expect(subject.errors[:description])
          .to include(I18n.t('activemodel.errors.models.accredited_provider_form.attributes.description.too_long'))
      end
    end
  end

  describe '#stash' do
    subject { described_class.new(user, model, params:).stash }

    let(:accredited_provider) { create(:provider, :accredited_provider) }
    let(:params) do
      {
        accredited_provider_id: accredited_provider.id,
        description: 'Foo'
      }
    end

    it { is_expected.to be_truthy }
  end

  describe '#save!' do
    subject { described_class.new(user, model, params:) }

    let(:accredited_provider) { create(:provider, :accredited_provider, users: [create(:user)]) }
    let(:params) do
      {
        accredited_provider_id: accredited_provider.id,
        description: 'Foo'
      }
    end

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
          { UcasProviderCode: existing_accredited_provider.provider_code, Description: 'Existing foo' }
        ]
      end

      let(:model) { create(:provider, accrediting_provider: 'N', accrediting_provider_enrichments:) }

      it 'updates the provider with the new accredited provider information' do
        subject.save!

        expect(model.accrediting_provider_enrichments.count).to eq(2)
        expect(model.accrediting_provider_enrichments.last.UcasProviderCode).to eq(accredited_provider.provider_code)
        expect(model.accrediting_provider_enrichments.last.Description).to eq('Foo')
      end
    end

    it 'sends a notification email to the accredited provider users' do
      expect(Users::OrganisationMailer).to receive(:added_as_an_organisation_to_training_partner).with(
        recipient: accredited_provider.users.first,
        provider: model,
        accredited_provider:
      ).and_call_original

      subject.save!
    end
  end
end
