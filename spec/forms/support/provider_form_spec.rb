# frozen_string_literal: true

require 'rails_helper'

require_relative '../shared_examples/blank_validation'

module Support
  describe ProviderForm, type: :model do
    let(:provider_form) { described_class.new(user, recruitment_cycle:, params:) }
    let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
    let(:user) { create(:user) }
    let(:base_params) do
      build(:provider).attributes.symbolize_keys.slice(
        :accredited,
        :accredited_provider_number,
        :provider_code,
        :provider_name,
        :provider_type,
        :ukprn,
        :urn
      )
    end
    let(:params) do
      test_params.reverse_merge(base_params)
    end
    let(:test_params) { {} }

    subject { provider_form }

    describe '#accredited?' do
      subject { provider_form.accredited? }

      context 'params accredited is true' do
        let(:test_params) do
          { accredited: '1' }
        end

        it 'returns true' do
          expect(subject).to be_truthy
        end
      end

      context 'params accredited is false' do
        let(:test_params) do
          { accredited: '0' }
        end

        it 'returns false' do
          expect(subject).to be_falsey
        end
      end
    end

    describe '#lead_school?' do
      subject { provider_form.lead_school? }

      context 'params provider_type is set to lead_school' do
        let(:test_params) do
          { provider_type: :lead_school }
        end

        it 'returns true' do
          expect(subject).to be_truthy
        end
      end

      context 'params provider_type is set to a non lead_school' do
        let(:test_params) do
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
        params.merge(organisations_attributes: [{ name: params[:provider_name] }])
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

      it 'shows the error messages for invalid provider code length' do
        expect(subject).to validate_length_of(:provider_code)
          .is_equal_to(3)
          .with_message('Provider code should be 3 characters')
      end

      it 'shows the error message for invalid provider code format' do
        expect(subject).not_to allow_values(
          'ggg',
          '11&',
          '11!',
          'GGG'
        )
          .for(:provider_code)
          .with_message('Enter a valid provider code (One number, at least, with numbers or uppercase letters)')
      end

      include_examples 'blank validation', :provider_name, 'Enter a provider name'
      include_examples 'blank validation', :provider_code, 'Enter a provider code'
      include_examples 'blank validation', :ukprn, 'Enter a UK provider reference number (UKPRN)'
      include_examples 'blank validation', :provider_type, 'Select a provider type'

      context 'provider_type is set to lead_school' do
        let(:test_params) do
          { provider_type: :lead_school }
        end

        include_examples 'blank validation', :urn, 'Enter a unique reference number (URN)'
      end

      context 'provider_type is set to lead_school and accredited is false' do
        let(:test_params) do
          {
            provider_type: :lead_school,
            accredited: '0'
          }
        end

        include_examples 'blank validation', :urn, 'Enter a unique reference number (URN)'
      end

      context 'accredited is true' do
        let(:test_params) do
          { accredited: '1' }
        end

        include_examples 'blank validation', :accredited_provider_number, 'Enter an accredited provider number'
      end

      context 'urn set to invalid' do
        let(:test_params) do
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
        let(:test_params) do
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
        let(:test_params) do
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

      context 'provider_type is set to lead_school and accredited is true' do
        let(:test_params) do
          {
            provider_type: :lead_school,
            accredited: true
          }
        end

        it 'validates the provider type' do
          expect(subject).not_to be_valid

          expect(subject.errors[:provider_type]).to match_array('Accredited provider cannot be a school')
        end
      end

      shared_examples 'accredited provider number validation' do |provider_type, accredited_provider_number, message|
        context "provider_type is set to '#{provider_type}' and accredited_provider_number is set to '#{accredited_provider_number}'" do
          let(:test_params) do
            {
              provider_type:,
              accredited: '1',
              accredited_provider_number:
            }
          end

          it 'validates the accredited provider number' do
            expect(subject).not_to be_valid

            expect(subject.errors[:accredited_provider_number]).to match_array(message)
          end
        end
      end

      blank_accredited_provider_number_message = 'Enter an accredited provider number'

      [nil, ''].each do |blank_accredited_provider_number|
        include_examples 'accredited provider number validation', nil, blank_accredited_provider_number, blank_accredited_provider_number_message
        include_examples 'accredited provider number validation', :scitt, blank_accredited_provider_number, blank_accredited_provider_number_message
        include_examples 'accredited provider number validation', :university, blank_accredited_provider_number, blank_accredited_provider_number_message
      end

      invalid_accredited_provider_number_message = 'Enter a valid accredited provider number'

      %w[a aaaa 12345 54321 abcde 1 5].each do |invalid_accredited_provider_number|
        include_examples 'accredited provider number validation', nil, invalid_accredited_provider_number, invalid_accredited_provider_number_message
        include_examples 'accredited provider number validation', :scitt, invalid_accredited_provider_number, invalid_accredited_provider_number_message
        include_examples 'accredited provider number validation', :university, invalid_accredited_provider_number, invalid_accredited_provider_number_message
      end

      include_examples 'accredited provider number validation', :scitt, '1234', invalid_accredited_provider_number_message
      include_examples 'accredited provider number validation', :university, '5432', invalid_accredited_provider_number_message
    end

    describe '#stash' do
      context 'valid details' do
        it 'returns true' do
          puts subject.params
          expect(subject.stash).to be true

          expect(subject.errors.messages).to be_blank
        end
      end
    end
  end
end
