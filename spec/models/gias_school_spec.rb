# frozen_string_literal: true

require "rails_helper"

describe GiasSchool do
  subject { build(:gias_school) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:urn) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }

  context "callbacks" do
    it "updates the tsvector column with relevant info when the school is updated" do
      school = create(:gias_school)

      expect {
        school.update(urn: "12345678", name: "St Leo's and Southmead/School", postcode: "sw1a 1aa", town: "london")
      }.to change { school.reload.searchable }.to(
        "'12345678':1 '1aa':13 'and':5,9 'leo':3 'leos':8 'london':15 's':4 'school':11 'southmead':10 'southmead/school':6 'st':2,7 'sw1a':12 'sw1a1aa':14",
      )
    end
  end

  describe "#school_attributes" do
    it "returns a hash of attributes that can be used to build a school" do
      school = build(:gias_school)

      expect(school.school_attributes).to eq(
        location_name: school.name,
        urn: school.urn,
        address1: school.address1,
        address2: school.address2,
        address3: school.address3,
        town: school.town,
        address4: school.county,
        postcode: school.postcode,
      )
    end
  end

  describe "#full_address" do
    it "includes location name in full address" do
      gias_school = build(
        :gias_school,
        name: "Southampton High School",
        address1: "5",
        address2: "Long Lane",
        address3: "Holbury",
        town: "Southampton",
        postcode: "SO45 2PA",
      )
      expect(gias_school.full_address).to eq("Southampton High School, 5, Long Lane, Holbury, Southampton, SO45 2PA")
    end

    it "skip nil attributes" do
      gias_school = build(
        :gias_school,
        name: "Southampton High School",
        address1: nil,
        address2: "Long Lane",
        address3: "Holbury",
        town: "Southampton",
        postcode: "SO45 2PA",
      )
      expect(gias_school.full_address).to eq("Southampton High School, Long Lane, Holbury, Southampton, SO45 2PA")
    end

    context "address is missing" do
      it "returns an empty string" do
        gias_school = build(
          :gias_school,
          name: "",
          address1: "",
          address2: "",
          address3: "",
          town: "",
          postcode: "",
        )

        expect(gias_school.full_address).to eq("")
      end
    end
  end
end
