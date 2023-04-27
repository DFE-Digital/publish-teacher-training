# frozen_string_literal: true

require 'rails_helper'

require_relative '../shared_examples/blank_validation'

module Publish
  describe ProviderContactForm, type: :model do
    subject { described_class.new(provider, params:) }

    let(:provider) { create(:provider) }
    let(:params) { {} }

    describe 'validations' do
      it { is_expected.to allow_value('12345').for(:urn) }
      it { is_expected.not_to allow_value('1234').for(:urn).with_message('URN must be 5 or 6 numbers') }

      include_examples 'blank validation', :email, 'Enter an email address in the correct format, like name@example.com'
      include_examples 'blank validation', :address1, 'Enter address line 1'
      include_examples 'blank validation', :town, 'Enter a town or city'
      include_examples 'blank validation', :postcode, 'Enter a postcode'
      include_examples 'blank validation', :website, 'Enter a website'

      context 'email set to invalid' do
        let(:params) do
          {
            email: 'jo@example'
          }
        end

        it 'validates the email' do
          expect(subject).not_to be_valid

          expect(subject.errors[:email]).to match_array('Enter an email address in the correct format, like name@example.com')
        end
      end

      context 'postcode set to invalid' do
        let(:params) do
          {
            postcode: 'tr1'
          }
        end

        it 'validates the postcode' do
          expect(subject).not_to be_valid

          expect(subject.errors[:postcode]).to match_array('Postcode is not valid (for example, BN1 1AA)')
        end
      end

      context 'telephone set to invalid' do
        let(:params) do
          {
            telephone: 'a'
          }
        end

        it 'validates the telephone' do
          expect(subject).not_to be_valid

          expect(subject.errors[:telephone]).to match_array('Enter a valid telephone number')
        end
      end

      context 'website set to invalid' do
        let(:params) do
          {
            website: 'www.example.com'
          }
        end

        it 'validates the website' do
          expect(subject).not_to be_valid

          expect(subject.errors[:website]).to match_array('Enter a website address in the correct format, like https://www.example.com')
        end
      end
    end
  end
end
