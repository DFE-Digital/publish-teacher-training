# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publish::AccreditedProviderUpdater do
  subject do
    described_class.new(provider_code:,
                        recruitment_cycle_year:,
                        new_accredited_provider_code:)
  end

  let(:provider_code) { 'A0' }
  let(:recruitment_cycle_year) { 2024 }
  let(:new_accredited_provider_code) { 'A1' }

  let!(:recruitment_cycle) { create(:recruitment_cycle, year: recruitment_cycle_year) }

  it 'fails with no exiting providers' do
    expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe '#update_provider' do
    let!(:new_accredited_provider) { create(:provider, provider_code: new_accredited_provider_code, recruitment_cycle:) }

    describe 'updates the providers updated_at' do
      let(:updated_at) { 1.week.ago.change(sec: 0) }
      let!(:provider) do
        create(:provider, :accredited_provider,
               provider_code:,
               recruitment_cycle:,
               accrediting_provider_enrichments: nil,
               updated_at:)
      end

      it "updates the course's Accrediting Provider" do
        expect { subject.update_provider }.to change { provider.reload.updated_at }.from(updated_at).to(be_within(1.minute).of(Time.zone.now))
      end
    end

    context 'when Provider is an Accredited Provider' do
      let!(:provider) do
        create(:provider, :accredited_provider,
               provider_code:,
               recruitment_cycle:,
               accrediting_provider_enrichments: nil)
      end

      it 'updates the provider' do
        subject.update_provider

        expect(provider.reload.accrediting_provider).to eq('not_an_accredited_provider')
        expect(provider.reload.accredited_providers).to include(new_accredited_provider)
      end
    end

    context 'when Provider has an Accredited Provider' do
      let!(:provider) do
        create(:provider,
               provider_code:,
               recruitment_cycle:,
               accrediting_provider: 'not_an_accredited_provider',
               accrediting_provider_enrichments: [{ UcasProviderCode: 'B1', Description: '' }])
      end
      let(:accredited_provider) { create(:provider, provider_code: 'B1', recruitment_cycle:) }

      it 'updates the provider' do
        subject.update_provider

        expect(provider.reload.accrediting_provider).to eq('not_an_accredited_provider')
        expect(provider.reload.accredited_providers).to include(accredited_provider, new_accredited_provider)
      end
    end

    context 'when Provider is already Accredited by the new Accredited Provider' do
      let!(:provider) do
        create(:provider,
               provider_code:,
               recruitment_cycle:,
               accrediting_provider: 'not_an_accredited_provider',
               accrediting_provider_enrichments: [{ UcasProviderCode: new_accredited_provider_code, Description: '' }])
      end

      it 'updates the provider' do
        subject.update_provider

        expect(provider.reload.accrediting_provider).to eq('not_an_accredited_provider')
        expect(provider.reload.accredited_providers).to include(new_accredited_provider)
        expect(provider.reload.accrediting_provider_enrichments.count).to eq(1)
      end
    end
  end

  describe '#update_courses' do
    let!(:provider) { create(:provider, provider_code:, recruitment_cycle:) }
    let!(:new_accredited_provider) { create(:provider, provider_code: new_accredited_provider_code, recruitment_cycle:) }

    describe 'updates the courses updated_at' do
      let(:updated_at) { 1.week.ago.change(sec: 0) }
      let!(:course) { create(:course, provider:, accredited_provider_code: nil, updated_at:) }

      it "updates the course's Accrediting Provider" do
        expect { subject.update_courses }.to change { course.reload.updated_at }.from(updated_at).to(be_within(1.minute).of(Time.zone.now))
      end
    end

    context 'when the course does not have an Accredited Provider' do
      let!(:course) { create(:course, provider:, accredited_provider_code: nil, updated_at: 1.week.ago) }

      it "updates the course's Accrediting Provider" do
        subject.update_courses

        expect(course.reload.accredited_provider_code).to eq(new_accredited_provider_code)
        expect(course.reload.updated_at).to be_within(1.minute).of(Time.zone.now)
      end
    end

    context 'when the course has an Accredited Provider' do
      let!(:course) { create(:course, provider:, accredited_provider_code: 'B1') }

      it "updates the course's Accrediting Provider" do
        subject.update_courses

        expect(course.reload.accredited_provider_code).to eq(new_accredited_provider_code)
      end
    end
  end
end
