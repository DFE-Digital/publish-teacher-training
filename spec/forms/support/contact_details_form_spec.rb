# frozen_string_literal: true

require 'rails_helper'

require_relative '../shared_examples/blank_validation'

module Support
  describe ContactDetailsForm, type: :model do
    subject { described_class.new(provider, params:) }

    let(:provider) { create(:provider) }
    let(:params) { {} }

    describe 'validations' do
      include_examples 'blank validation', :email, 'Enter an email address in the correct format, like name@example.com'
      include_examples 'blank validation', :telephone, 'Enter a telephone number'
      include_examples 'blank validation', :address1, 'Enter address line 1'
      include_examples 'blank validation', :town, 'Enter a town or city'
      include_examples 'blank validation', :postcode, 'Enter a postcode'

      context 'website' do
        context 'set to blank' do
          let(:params) do
            {
              website: ''
            }
          end

          it 'validates the website' do
            expect(subject).not_to be_valid

            expect(subject.errors[:website]).to contain_exactly('Enter a website address', 'Enter a website address in the correct format, like https://www.example.com')
          end
        end

        context 'set to invalid' do
          let(:params) do
            {
              website: 'gibberish'
            }
          end

          it 'validates the website' do
            expect(subject).not_to be_valid

            expect(subject.errors[:website]).to contain_exactly('Enter a website address in the correct format, like https://www.example.com')
          end
        end
      end

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

          expect(subject.errors[:postcode]).to match_array('Enter a real postcode')
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

          expect(subject.errors[:telephone]).to match_array('Enter a telephone number, like 01632 960 001, 07700 900 982 or +44 0808 157 0192')
        end
      end
    end
  end
end
