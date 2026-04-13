# frozen_string_literal: true

require "rails_helper"

describe Course::School do
  subject(:course_school) { build(:course_school) }

  describe "associations" do
    it { is_expected.to belong_to(:course) }
    it { is_expected.to belong_to(:gias_school) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:site_code) }
    it { is_expected.to validate_presence_of(:gias_school_id) }

    it "creates a valid record" do
      expect(course_school).to be_valid
    end

    it "rejects a duplicate (course, gias_school, site_code) triple" do
      existing = create(:course_school)
      dup = build(
        :course_school,
        course: existing.course,
        gias_school: existing.gias_school,
        site_code: existing.site_code,
      )
      expect(dup).not_to be_valid
      expect(dup.errors[:gias_school_id]).to be_present
    end

    it "allows the same course and gias_school with different site codes" do
      existing = create(:course_school, site_code: "-")
      second = build(
        :course_school,
        course: existing.course,
        gias_school: existing.gias_school,
        site_code: "A",
      )
      expect(second).to be_valid
    end
  end

  describe "database constraints" do
    let(:course) { create(:course) }
    let(:gias_school) { create(:gias_school) }

    it "enforces NOT NULL on course_id" do
      expect {
        described_class.new(gias_school:, site_code: "-").save(validate: false)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "enforces NOT NULL on gias_school_id" do
      expect {
        described_class.new(course:, site_code: "-").save(validate: false)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "enforces NOT NULL on site_code" do
      expect {
        described_class.new(course:, gias_school:).save(validate: false)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "enforces the gias_school_id foreign key" do
      missing_id = GiasSchool.maximum(:id).to_i + 1_000
      record = described_class.new(course:, site_code: "-")
      record.gias_school_id = missing_id
      expect {
        record.save(validate: false)
      }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    it "enforces DB-level uniqueness on (course_id, gias_school_id, site_code)" do
      existing = create(:course_school)
      expect {
        described_class.new(
          course: existing.course,
          gias_school: existing.gias_school,
          site_code: existing.site_code,
        ).save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
