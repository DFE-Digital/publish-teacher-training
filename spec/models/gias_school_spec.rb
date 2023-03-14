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
end
