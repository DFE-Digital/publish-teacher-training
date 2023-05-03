# frozen_string_literal: true

require 'rails_helper'

module Support
  describe GotoConfirmationHelper do
    let(:param_form_key) { :param_form_key }

    describe '#goto_confirmation_value' do
      subject do
        goto_confirmation_value(param_form_key:, params:)
      end

      context 'params is empty' do
        let(:params) { {} }

        it 'returns falsey' do
          expect(subject).to be_nil
        end
      end

      context 'params has goto_confirmation set to "true"' do
        let(:params) { { goto_confirmation: 'true' } }

        it 'returns truthy' do
          expect(subject).to eq('true')
        end
      end

      context 'params has param_form_key with goto_confirmation set to "true"' do
        let(:params) { { param_form_key: { goto_confirmation: 'true' } } }

        it 'returns truthy' do
          expect(subject).to eq('true')
        end
      end
    end

    describe '#goto_confirmation?' do
      subject do
        goto_confirmation?(param_form_key:, params:)
      end

      context 'params is empty' do
        let(:params) { {} }

        it 'returns falsey' do
          expect(subject).to be_falsey
        end
      end

      context 'params has goto_confirmation set to "true"' do
        let(:params) { { goto_confirmation: 'true' } }

        it 'returns truthy' do
          expect(subject).to be_truthy
        end
      end

      context 'params has param_form_key with goto_confirmation set to "true"' do
        let(:params) { { param_form_key: { goto_confirmation: 'true' } } }

        it 'returns truthy' do
          expect(subject).to be_truthy
        end
      end
    end

    describe '#back_link_for_onboarding_path' do
      let(:recruitment_cycle) { build(:recruitment_cycle) }

      subject do
        back_link_for_onboarding_path(param_form_key:,
                                      params:,
                                      recruitment_cycle_year: recruitment_cycle.year)
      end

      context 'params is empty' do
        let(:params) { {} }

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end

      context 'params has goto_confirmation set to "true"' do
        let(:params) { { goto_confirmation: 'true' } }

        it 'returns onboarding check url' do
          expect(subject).to eq(
            "/support/#{recruitment_cycle.year}/providers/onboarding/check"
          )
        end
      end

      context 'params has param_form_key with goto_confirmation set to "true"' do
        let(:params) { { param_form_key: { goto_confirmation: 'true' } } }

        it 'returns onboarding check url' do
          expect(subject).to eq(
            "/support/#{recruitment_cycle.year}/providers/onboarding/check"
          )
        end
      end

      context 'param_form_key set as support_provider_form and with no params' do
        let(:param_form_key) { :support_provider_form }

        let(:params) { {} }

        it 'returns onboarding check url' do
          expect(subject).to eq(
            "/support/#{recruitment_cycle.year}/providers"
          )
        end
      end

      context 'param_form_key set as support_provider_contact_form and with no params' do
        let(:param_form_key) { :support_provider_contact_form }

        let(:params) { {} }

        it 'returns onboarding check url' do
          expect(subject).to eq(
            "/support/#{recruitment_cycle.year}/providers/onboarding/new"
          )
        end
      end
    end
  end
end
