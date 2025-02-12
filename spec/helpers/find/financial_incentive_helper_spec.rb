# frozen_string_literal: true

require 'rails_helper'

module Find
  describe FinancialIncentiveHelper do
    describe '#financial_information' do
      let(:financial_incentive) { instance_double(FinancialIncentive, scholarship: scholarship, bursary_amount: bursary_amount) }
      let(:scholarship) { nil }
      let(:bursary_amount) { nil }

      before do
        allow(FeatureFlag).to receive(:active?).with(:bursaries_and_scholarships_announced).and_return(true)
      end

      context 'when financial_incentive has both scholarship and bursary' do
        let(:scholarship) { 3000 }
        let(:bursary_amount) { 2000 }

        it 'returns formatted bursary and scholarship information' do
          expect(helper.financial_information(financial_incentive)).to eq('Scholarships of £3,000 or bursaries of £2,000 are available')
        end
      end

      context 'when financial_incentive has only bursary' do
        let(:bursary_amount) { 5000 }

        it 'returns formatted bursary information' do
          expect(helper.financial_information(financial_incentive)).to eq('Bursaries of £5,000 are available')
        end
      end

      context 'when financial_incentive has only scholarship' do
        let(:scholarship) { 5000 }

        it 'returns formatted scholarship information' do
          expect(helper.financial_information(financial_incentive)).to eq('Scholarships of £5,000 are available')
        end
      end

      context 'when financial_incentive has neither scholarship nor bursary' do
        it 'returns nil' do
          expect(helper.financial_information(financial_incentive)).to be_nil
        end
      end

      context 'when feature flag is disabled' do
        before do
          allow(FeatureFlag).to receive(:active?).with(:bursaries_and_scholarships_announced).and_return(false)
        end

        it 'returns nil' do
          expect(helper.financial_information(financial_incentive)).to be_nil
        end
      end
    end
  end
end
