# frozen_string_literal: true

require 'rails_helper'

describe Sites::CodeGenerator do
  subject { described_class.call(provider:) }

  let(:provider) { create(:provider) }

  it 'generates a UCAS style code (one of A-Z, 0-9 or -)' do
    expect(subject).to match(/\A[A-Z0-9-]{1}\z/)
  end

  context 'when UCAS style codes exist' do
    before do
      (Site::DESIRABLE_CODES - %w[A]).each { |code| create(:site, code:, provider:) }
    end

    it 'generates easily-confused codes only when all others have been used up' do
      expect(subject).to eq('A')
    end
  end

  context 'when all of UCAS style POSSIBLE_CODES are assigned' do
    before do
      Site::POSSIBLE_CODES.each { |code| create(:site, code:, provider:) }
    end

    it 'generates codes starting with AA' do
      expect(subject).to eq('AA')
    end
  end

  context 'when sequential codes exist' do
    before do
      Site::POSSIBLE_CODES.each { |code| create(:site, code:, provider:) }
      create_list(:site, 3, code: nil, provider:)
    end

    it 'generates the next available code' do
      expect(subject).to eq('AD')
    end
  end
end
