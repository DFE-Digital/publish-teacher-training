# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publish::UpdateAccreditedProvider do
  subject do
    described_class.new(training_provider_code:,
                        to_provider_code:,
                        recruitment_cycle_year:)
  end

  let(:training_provider_code) { 'T0' }
  let(:to_provider_code) { 'A1' }
  let(:recruitment_cycle_year) { 2024 }

  let!(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: recruitment_cycle_year) }

  it 'fails with no exiting providers' do
    expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe '#update_provider' do
    let!(:to_provider) { create(:provider, provider_code: to_provider_code, recruitment_cycle:) }

    context 'when Provider is an Accredited Provider' do
      let!(:provider) do
        create(:provider, :accredited_provider,
               provider_code: training_provider_code,
               recruitment_cycle:,
               accrediting_provider_enrichments: nil)
      end

      it 'updates the provider' do
        subject.update_provider

        expect(provider.reload.accrediting_provider).to eq('not_an_accredited_provider')
        expect(provider.reload.accredited_providers).to include(to_provider)
      end
    end

    context 'when Provider has an Accredited Provider' do
      let!(:provider) do
        create(:provider,
               provider_code: training_provider_code,
               recruitment_cycle:,
               accrediting_provider: 'not_an_accredited_provider',
               accrediting_provider_enrichments: [{ UcasProviderCode: 'B1', Description: '' }])
      end
      let(:accredited_provider) { create(:provider, provider_code: 'B1', recruitment_cycle:) }

      it 'updates the provider' do
        subject.update_provider

        expect(provider.reload.accrediting_provider).to eq('not_an_accredited_provider')
        expect(provider.reload.accredited_providers).to include(accredited_provider, to_provider)
      end
    end

    context 'when Provider is already Accredited by the new Accredited Provider' do
      let!(:provider) do
        create(:provider,
               provider_code: training_provider_code,
               recruitment_cycle:,
               accrediting_provider: 'not_an_accredited_provider',
               accrediting_provider_enrichments: [{ UcasProviderCode: to_provider_code, Description: '' }])
      end

      it 'updates the provider' do
        subject.update_provider

        expect(provider.reload.accrediting_provider).to eq('not_an_accredited_provider')
        expect(provider.reload.accredited_providers).to include(to_provider)
        expect(provider.reload.accrediting_provider_enrichments.count).to eq(1)
      end
    end
  end

  describe '#update_courses' do
    let!(:training_provider) { create(:provider, provider_code: training_provider_code, recruitment_cycle:) }
    let!(:to_provider) { create(:provider, provider_code: to_provider_code, recruitment_cycle:) }

    context 'when the accredited_provider is blank' do
      let!(:course) { create(:course, provider: training_provider, accredited_provider_code: nil) }

      it "changes the course's Accrediting Provider" do
        expect { subject.update_courses }.to(change { course.reload.accredited_provider_code }.from(nil).to('A1'))
      end
    end

    context 'when the accredited_provider is not target or source' do
      let!(:course) { create(:course, provider: training_provider, accredited_provider_code: 'A2') }

      it "changes the course's Accrediting Provider" do
        expect { subject.update_courses }.to(change { course.reload.accredited_provider_code }.from('A2').to('A1'))
      end
    end

    context 'when the accredited_provider is target' do
      let!(:course) { create(:course, provider: training_provider, accredited_provider_code: 'A1') }

      it "does not change course's Accrediting Provider" do
        expect { subject.update_courses }.not_to(change { course.reload.accredited_provider_code })
      end
    end
  end

  describe '#update_users' do
    let!(:to_provider) { create(:provider, provider_code: to_provider_code, recruitment_cycle:) }

    context 'when the original accredited_provider has users with permissions on the training provider' do
      let!(:training_provider) do
        create(:provider,
               provider_code: training_provider_code,
               recruitment_cycle:,
               accrediting_provider: 'not_an_accredited_provider',
               accrediting_provider_enrichments: [{ UcasProviderCode: 'B1', Description: '' }])
      end
      let(:old_accredited_provider) { create(:provider, provider_code: 'B1', recruitment_cycle:) }
      let!(:user_to_remove) { create(:user, providers: [training_provider, old_accredited_provider]) }
      let!(:user_to_add) { create(:user, providers: [to_provider]) }

      it "changes the course's Accrediting Provider" do
        expect(user_to_remove.reload.user_permissions.pluck(:provider_id)).to include(training_provider.id)
        expect(user_to_add.reload.user_permissions.pluck(:provider_id)).not_to include(training_provider.id)

        subject.call

        expect(user_to_add.reload.user_permissions.pluck(:provider_id)).to include(training_provider.id)
        expect(user_to_remove.reload.user_permissions.pluck(:provider_id)).not_to include(training_provider.id)
      end
    end
  end
end
