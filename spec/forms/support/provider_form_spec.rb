# frozen_string_literal: true

require 'rails_helper'

require_relative '../shared_examples/blank_validation'

module Support
  describe ProviderForm, type: :model do
    let(:provider_form) { described_class.new(user, recruitment_cycle:, params:) }
    let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
    let(:user) { create(:user) }
    let(:params) do
      build(:provider).attributes.symbolize_keys.slice(
        :accrediting_provider,
        :accredited_provider_id,
        :provider_code,
        :provider_name,
        :provider_type,
        :ukprn,
        :urn
      ).transform_keys { |key| key == :accrediting_provider ? :accredited_provider : key }
    end

    subject { provider_form }

    describe '#accredited_provider?' do
      subject { provider_form.accredited_provider? }

      context 'params accredited_provider is set to accredited_provider' do
        let(:params) do
          { accredited_provider: :accredited_provider }
        end

        it 'returns true' do
          expect(subject).to be_truthy
        end
      end

      context 'params accredited_provider is set to a not_an_accredited_provider' do
        let(:params) do
          { accredited_provider: :not_an_accredited_provider }
        end

        it 'returns false' do
          expect(subject).to be_falsey
        end
      end
    end

    describe '#lead_school?' do
      subject { provider_form.lead_school? }

      context 'params provider_type is set to lead_school' do
        let(:params) do
          { provider_type: :lead_school }
        end

        it 'returns true' do
          expect(subject).to be_truthy
        end
      end

      context 'params provider_type is set to a non lead_school' do
        let(:params) do
          { provider_type: %i[university scitt].sample }
        end

        it 'returns false' do
          expect(subject).to be_falsey
        end
      end
    end

    describe '#attributes_to_save' do
      subject { provider_form.attributes_to_save }
      let(:expected_attributes) do
        params.transform_keys { |key| key == :accredited_provider ? :accrediting_provider : key }
              .merge(organisations_attributes: [{ name: params[:provider_name] }])
              .merge(recruitment_cycle:)
      end

      it 'matches the expected attributes' do
        expect(subject).to match(expected_attributes)
      end
    end

    describe 'validations' do
      it {
        expect(subject).to validate_length_of(:provider_name)
          .is_at_most(100)
          .with_message('Enter a provider name that is 100 characters or fewer')
      }

      it {
        expect(subject).to validate_length_of(:provider_code)
          .is_equal_to(3)
          .with_message('Enter a valid provider code')
      }

      include_examples 'blank validation', :provider_name, 'Enter a provider name'
      include_examples 'blank validation', :provider_code, 'Enter a provider code'
      include_examples 'blank validation', :ukprn, 'Enter a UK provider reference number (UKPRN)'
      include_examples 'blank validation', :provider_type, 'Select a provider type'
      include_examples 'blank validation', :accredited_provider, 'Select if the organisation is an accredited provider'

      context 'provider_type is set to lead_school' do
        let(:params) do
          { provider_type: :lead_school }
        end

        include_examples 'blank validation', :urn, 'Enter a unique reference number (URN)'
      end

      context 'provider_type is set to lead_school and accredited_provider is set to not_an_accredited_body' do
        let(:params) do
          {
            provider_type: :lead_school,
            accredited_provider: :not_an_accredited_body
          }
        end

        include_examples 'blank validation', :urn, 'Enter a unique reference number (URN)'
      end

      context 'accredited_provider is set to accredited_body' do
        let(:params) do
          { accredited_provider: :accredited_provider }
        end

        include_examples 'blank validation', :accredited_provider_id, 'Enter an accredited provider ID'
      end

      context 'urn set to invalid' do
        let(:params) do
          {
            provider_type: :lead_school,
            urn: %w[1234 1234567 digit].sample
          }
        end

        it 'validates the urn' do
          expect(subject).not_to be_valid

          expect(subject.errors[:urn]).to match_array('Enter a valid unique reference number (URN)')
        end
      end

      context 'ukprn set to invalid' do
        let(:params) do
          {
            ukprn: %w[1234567 123456789 digit].sample
          }
        end

        it 'validates the ukprn' do
          expect(subject).not_to be_valid

          expect(subject.errors[:ukprn]).to match_array('Enter a valid UK provider reference number (UKPRN) - it must be 8 digits starting with a 1, like 12345678')
        end
      end

      context 'using an existing provider_code' do
        let(:params) do
          { provider_code: }
        end

        let(:provider_code) do
          create(:provider).provider_code
        end

        it 'validates the provider code' do
          expect(subject).not_to be_valid

          expect(subject.errors[:provider_code]).to match_array('Provider code already taken')
        end
      end

      context 'provider_type is set to lead_school and accredited_provider is set to accredited_body' do
        let(:params) do
          {
            provider_type: :lead_school,
            accredited_provider: :accredited_provider
          }
        end

        it 'validates the provider type' do
          expect(subject).not_to be_valid

          expect(subject.errors[:provider_type]).to match_array('Accredited provider cannot be a school')
        end
      end

      shared_examples 'accredited provider id validation' do |provider_type, accredited_provider_id, message|
        context "provider_type is set to '#{provider_type}' and accredited_provider_id is set to '#{accredited_provider_id}'" do
          let(:params) do
            {
              provider_type:,
              accredited_provider: :accredited_provider,
              accredited_provider_id:
            }
          end

          it 'validates the accredited provider id' do
            expect(subject).not_to be_valid

            expect(subject.errors[:accredited_provider_id]).to match_array(message)
          end
        end
      end

      blank_accredited_provider_id_message = 'Enter an accredited provider ID'

      [nil, ''].each do |blank_accredited_provider_id|
        include_examples 'accredited provider id validation', nil, blank_accredited_provider_id, blank_accredited_provider_id_message
        include_examples 'accredited provider id validation', :scitt, blank_accredited_provider_id, blank_accredited_provider_id_message
        include_examples 'accredited provider id validation', :university, blank_accredited_provider_id, blank_accredited_provider_id_message
      end

      invalid_accredited_provider_id_message = 'Enter a valid accredited provider ID'

      %w[a aaaa 12345 54321 abcde 1 5].each do |invalid_accredited_provider_id|
        include_examples 'accredited provider id validation', nil, invalid_accredited_provider_id, invalid_accredited_provider_id_message
        include_examples 'accredited provider id validation', :scitt, invalid_accredited_provider_id, invalid_accredited_provider_id_message
        include_examples 'accredited provider id validation', :university, invalid_accredited_provider_id, invalid_accredited_provider_id_message
      end

      include_examples 'accredited provider id validation', :scitt, '1234', invalid_accredited_provider_id_message
      include_examples 'accredited provider id validation', :university, '5432', invalid_accredited_provider_id_message
    end

    describe '#stash' do
      context 'valid details' do
        it 'returns true' do
          expect(subject.stash).to be true

          expect(subject.errors.messages).to be_blank
        end
      end
    end
  end
end
