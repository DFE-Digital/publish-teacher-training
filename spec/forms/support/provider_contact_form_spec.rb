# frozen_string_literal: true

require 'rails_helper'

require_relative '../shared_examples/blank_validation'

module Support
  describe ProviderContactForm, type: :model do
    subject { described_class.new(user, params:) }

    let(:user) { create(:user) }
    let(:params) { {} }

    describe 'validations' do
      include_examples 'blank validation', :email, 'Enter an email address'
      include_examples 'blank validation', :telephone, 'Enter a telephone number'
      include_examples 'blank validation', :website, 'Enter a website address'
      include_examples 'blank validation', :address1, 'Enter address line 1'
      include_examples 'blank validation', :town, 'Enter a town or city'
      include_examples 'blank validation', :postcode, 'Enter a postcode'

      context 'telephone set to invalid' do
        let(:params) do
          {
            telephone: 'a'
          }
        end

        it 'validates the telephone' do
          expect(subject).not_to be_valid

          expect(subject.errors[:telephone]).to match_array('Enter a telephone number, like 01632 960 001, 07700 900 982 or +44 0808 157 0192')
        end
      end

      context 'telephone set to nil' do
        let(:params) do
          {
            telephone: nil
          }
        end

        it 'validates the telephone' do
          expect(subject).not_to be_valid

          expect(subject.errors[:telephone]).to match_array('Enter a telephone number')
        end
      end

      context 'telephone set to long number' do
        let(:params) do
          {
            telephone: '123456791123456789'
          }
        end

        it 'validates the telephone' do
          expect(subject).not_to be_valid

          expect(subject.errors[:telephone]).to match_array('Telephone number must contain 15 numbers or fewer')
        end
      end

      context 'telephone set to short number' do
        let(:params) do
          {
            telephone: '1234567'
          }
        end

        it 'validates the telephone' do
          expect(subject).not_to be_valid

          expect(subject.errors[:telephone]).to match_array('Telephone number must contain 8 numbers or more')
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
