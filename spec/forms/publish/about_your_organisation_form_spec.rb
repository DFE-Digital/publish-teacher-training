# frozen_string_literal: true

require 'rails_helper'

module Publish
  describe AboutYourOrganisationForm, type: :model do
    include Rails.application.routes.url_helpers
    let(:params) do
      {
        train_with_us:,
        train_with_disability:
      }
    end
    let(:train_with_us) { 'train_with_us' }
    let(:train_with_disability) { 'train_with_disability' }
    let(:provider) do
      create(
        :provider,
        accrediting_provider_enrichments: [
          { UcasProviderCode: accredited_provider.provider_code }
        ]
      )
    end
    let(:accredited_provider) { create(:provider, :accredited_provider) }
    let(:redirect_params) { { 'goto_preview' => 'true' } }
    let(:course_code) { create(:course) }

    subject { described_class.new(provider, params:, redirect_params:, course_code:) }

    context 'validations' do
      it { is_expected.to validate_presence_of(:train_with_us).with_message('Enter details about training with you') }
      it { is_expected.to validate_presence_of(:train_with_disability).with_message('Enter details about training with a disability') }

      context 'traing_with_us word count is invalid' do
        let(:train_with_us) { Faker::Lorem.sentence(word_count: 251) }

        it 'is not valid when traing_with_us is over 250 words' do
          expect(subject.valid?).to be_falsey
          expect(subject.errors[:train_with_us]).to include('Reduce the word count for training with you')
        end
      end

      context 'train_with_disability word count is invalid' do
        let(:train_with_disability) { Faker::Lorem.sentence(word_count: 251) }

        it 'is not valid when train_with_disability is over 250 words' do
          expect(subject.valid?).to be_falsey
          expect(subject.errors[:train_with_disability]).to include('Reduce the word count for training with disabilities and other needs')
        end
      end
    end

    describe '#accredited_bodies' do
      it 'returns an array of accredited_providers' do
        expect(subject.accredited_bodies).to include(
          have_attributes(
            provider_name: accredited_provider.provider_name,
            provider_code: accredited_provider.provider_code
          )
        )
      end
    end

    describe '#update_success_path' do
      context 'when goto_preview is true' do
        it 'returns the goto_preview path' do
          expect(subject.update_success_path).to eq(
            preview_publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              provider.recruitment_cycle_year,
              course_code
            )
          )
        end
      end

      context 'when goto_provider is true' do
        let(:redirect_params) { { 'goto_provider' => 'true' } }

        it 'returns the goto_provider path' do
          expect(subject.update_success_path).to eq(
            provider_publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              provider.recruitment_cycle_year,
              course_code
            )
          )
        end
      end

      context 'when goto_training_with_disabilities is true' do
        let(:redirect_params) { { 'goto_training_with_disabilities' => 'true' } }

        it 'returns the goto_training_with_disabilities path' do
          expect(subject.update_success_path).to eq(
            training_with_disabilities_publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              provider.recruitment_cycle_year,
              course_code
            )
          )
        end
      end

      context 'when there is no redirect_params' do
        let(:redirect_params) { {} }

        it 'returns the details path' do
          expect(subject.update_success_path).to eq(
            details_publish_provider_recruitment_cycle_path(
              provider.provider_code,
              provider.recruitment_cycle_year
            )
          )
        end
      end
    end
  end
end
