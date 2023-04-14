# frozen_string_literal: true

require 'rails_helper'

describe GiasSchool do
  subject { build(:gias_school) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:urn) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:address1) }
  it { is_expected.to validate_presence_of(:town) }
  it { is_expected.to validate_presence_of(:postcode) }
  it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }

  context 'callbacks' do
    it 'updates the tsvector column with relevant info when the school is updated' do
      school = create(:gias_school)

      expect do
        school.update(urn: '12345678', name: "St Leo's and Southmead/School", postcode: 'sw1a 1aa', town: 'london')
      end.to change { school.reload.searchable }.to(
        "'12345678':1 '1aa':13 'and':5,9 'leo':3 'leos':8 'london':15 's':4 'school':11 'southmead':10 'southmead/school':6 'st':2,7 'sw1a':12 'sw1a1aa':14"
      )
    end
  end
end
