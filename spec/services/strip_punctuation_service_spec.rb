# frozen_string_literal: true

require 'rails_helper'

describe StripPunctuationService do
  it 'returns nil' do
    expect(described_class.call(string: nil)).to be_nil
  end

  it 'strips quotes' do
    expect(described_class.call(string: 'Samantha "Sam" O\'Hara')).to eq('Samantha Sam OHara')
  end

  it 'strips curly quotes' do
    expect(described_class.call(string: 'Samantha “Sam” O’Hara')).to eq('Samantha Sam OHara')
  end

  it 'strips out full stops' do
    expect(described_class.call(string: "St. Paul's With St. Michael's")).to eq('St Pauls With St Michaels')
  end

  it 'replaces special characters with spaces' do
    expect(described_class.call(string: 'Peakirk-Cum-Glinton School,Peterborough')).to eq('Peakirk Cum Glinton School Peterborough')
  end
end
