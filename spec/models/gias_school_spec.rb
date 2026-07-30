# frozen_string_literal: true

require "rails_helper"

describe GiasSchool do
  subject { build(:gias_school) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:urn) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }

  context "scopes" do
    describe ".for_course_level" do
      def school(phase_code:, minimum_age: nil, maximum_age: nil)
        create(:gias_school, phase_code:, minimum_age:, maximum_age:)
      end

      def levels_showing(record)
        %w[primary secondary further_education].select do |level|
          described_class.for_course_level(level).exists?(id: record.id)
        end
      end

      # Phase codes that belong to a level outright.
      {
        nursery: %w[primary],
        primary: %w[primary],
        middle_deemed_primary: %w[primary],
        secondary: %w[secondary],
        middle_deemed_secondary: %w[secondary],
        all_through: %w[primary secondary],
        sixteen_plus: %w[further_education],
      }.each do |phase_code, expected_levels|
        it "shows a #{phase_code} school on #{expected_levels.join(' and ')} courses" do
          expect(levels_showing(school(phase_code:))).to eq(expected_levels)
        end
      end

      # "Not applicable" is the largest phase in GIAS, segmented by age range.
      describe "not applicable schools" do
        {
          # minimum, maximum => levels
          [nil, nil] => %w[primary secondary further_education],
          ["", ""] => %w[primary secondary further_education],
          %w[3 7] => %w[primary],
          %w[3 18] => %w[primary secondary],
          ["8", nil] => %w[primary],
          # Primary needs min <= 8, so 9 is secondary only even though the
          # secondary rule's second clause allows min <= 9.
          ["9", nil] => %w[secondary],
          %w[9 16] => %w[secondary],
          ["10", nil] => %w[secondary],
          ["14", nil] => %w[secondary],
          ["15", nil] => %w[further_education],
          %w[16 19] => %w[further_education],
        }.each do |(minimum_age, maximum_age), expected_levels|
          it "shows min #{minimum_age.inspect} max #{maximum_age.inspect} on #{expected_levels.join(', ')}" do
            record = school(phase_code: :not_applicable, minimum_age:, maximum_age:)

            expect(levels_showing(record)).to eq(expected_levels)
          end
        end
      end

      # Fail open: never hide a school because its GIAS data is unusable.
      describe "unclassifiable schools" do
        it "shows a school with no phase code on every level" do
          record = create(:gias_school)
          record.update_column(:phase_code, nil)

          expect(levels_showing(record)).to eq(%w[primary secondary further_education])
        end

        it "shows a school with a blank phase code on every level" do
          record = create(:gias_school)
          record.update_column(:phase_code, "")

          expect(levels_showing(record)).to eq(%w[primary secondary further_education])
        end

        it "shows a school with a phase code this enum does not know on every level" do
          record = create(:gias_school)
          record.update_column(:phase_code, "99")

          expect(levels_showing(record)).to eq(%w[primary secondary further_education])
        end
      end

      # minimum_age/maximum_age are free text straight from the GIAS export.
      describe "junk age data" do
        it "does not raise on a non-numeric age" do
          record = school(phase_code: :not_applicable, minimum_age: "n/a", maximum_age: "unknown")

          expect { levels_showing(record) }.not_to raise_error
        end

        it "treats a non-numeric minimum age as unclassifiable" do
          record = school(phase_code: :not_applicable, minimum_age: "n/a")

          expect(levels_showing(record)).to eq(%w[primary secondary further_education])
        end

        it "reads a padded age" do
          record = school(phase_code: :not_applicable, minimum_age: " 11 ")

          expect(levels_showing(record)).to eq(%w[secondary])
        end
      end

      it "does not filter when the level is not one we segment on" do
        record = school(phase_code: :secondary)

        expect(described_class.for_course_level(nil)).to include(record)
        expect(described_class.for_course_level("something_else")).to include(record)
      end

      # The predicate is one disjunction in a raw SQL fragment, and Rails ANDs
      # those without wrapping them. Without the outer parentheses it would
      # swallow every other condition on the relation.
      it "keeps its disjunction parenthesised when chained" do
        primary = school(phase_code: :primary)
        secondary = school(phase_code: :secondary)

        result = described_class.for_course_level("primary").where(id: [primary.id, secondary.id])

        expect(result).to contain_exactly(primary)
      end
    end

    describe ".available" do
      it "returns open and proposed_to_open, not closed or proposed_to_close" do
        open = create(:gias_school, :open)
        proposed_close = create(:gias_school, status_code: :proposed_to_close)

        closed = create(:gias_school, :closed)
        proposed_open = create(:gias_school, status_code: :proposed_to_open)

        result = described_class.available.ids

        expect(result).to contain_exactly(open.id, proposed_close.id, proposed_open.id)
        expect(result).not_to contain_exactly(closed.id)
      end
    end
  end

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
