# frozen_string_literal: true

require 'rails_helper'

describe GiasSchool do
  subject do
    described_class.new(
      urn: '100000',
      name: 'school name',
      address1: 'the address',
      town: 'anytown',
      postcode: 'postcode'
    )
  end

  it 'is valid with required attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid without urn' do
    subject.urn = ''
    expect(subject).not_to be_valid
  end

  it 'is invalid without name' do
    subject.name = ''
    expect(subject).not_to be_valid
  end

  it 'is invalid without address1' do
    subject.address1 = ''
    expect(subject).not_to be_valid
  end

  it 'is invalid without town' do
    subject.town = ''
    expect(subject).not_to be_valid
  end

  it 'is invalid without postcode' do
    subject.postcode = ''
    expect(subject).not_to be_valid
  end

  it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }
end
