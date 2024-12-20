# frozen_string_literal: true

require 'rails_helper'

module Constraints
  RSpec.describe PartnershipFeature do
    describe 'when the feature is on' do
      before do
        allow(Settings.features).to receive(:provider_partnerships).and_return(true)
      end

      context 'when we pass :on' do
        let(:constraint) { described_class.new(:on) }

        it 'matches' do
          expect(constraint.matches?(nil)).to be_truthy
        end
      end

      context 'when we pass :off' do
        let(:constraint) { described_class.new(:off) }

        it 'does not match' do
          expect(constraint.matches?(nil)).to be_falsey
        end
      end
    end

    describe 'when the feature is off' do
      before do
        allow(Settings.features).to receive(:provider_partnerships).and_return(false)
      end

      context 'when we pass :on' do
        let(:constraint) { described_class.new(:on) }

        it 'does not match' do
          expect(constraint.matches?(nil)).to be_falsey
        end
      end

      context 'when we pass :off' do
        let(:constraint) { described_class.new(:off) }

        it 'matches' do
          expect(constraint.matches?(nil)).to be_truthy
        end
      end
    end
  end
end
