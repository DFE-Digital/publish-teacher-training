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

    it "allows the same course and gias_school when one relationship is a main site" do
      existing = create(:course_school, site_code: "-")
      second = build(
        :course_school,
        course: existing.course,
        gias_school: existing.gias_school,
        site_code: "A",
      )
      expect(second).to be_valid
    end

    it "rejects the same course and gias_school with different non-main site codes" do
      existing = create(:course_school, site_code: "A")
      second = build(
        :course_school,
        course: existing.course,
        gias_school: existing.gias_school,
        site_code: "B",
      )
      expect(second).not_to be_valid
      expect(second.errors[:gias_school_id]).to be_present
    end
  end

  describe "touching the course" do
    let(:course) { create(:course, changed_at: 1.hour.ago) }

    it "bumps course.changed_at on create" do
      Timecop.freeze do
        create(:course_school, course:)
        expect(course.reload.changed_at).to be_within(1.second).of(Time.zone.now)
      end
    end

    it "bumps course.changed_at on update" do
      course_school = create(:course_school, course:)
      course.update_columns(changed_at: 1.hour.ago)

      Timecop.freeze do
        course_school.update!(site_code: "Z")
        expect(course.reload.changed_at).to be_within(1.second).of(Time.zone.now)
      end
    end

    it "does not bump course.changed_at on destroy" do
      course_school = create(:course_school, course:)
      course.update_columns(changed_at: 1.hour.ago)
      before_changed_at = course.reload.changed_at

      course_school.destroy!
      expect(course.reload.changed_at).to be_within(1.second).of(before_changed_at)
    end

    it "leaves course.updated_at unchanged" do
      course.update_columns(updated_at: 1.hour.ago)
      original_updated_at = course.reload.updated_at

      create(:course_school, course:)
      expect(course.reload.updated_at).to be_within(1.second).of(original_updated_at)
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
