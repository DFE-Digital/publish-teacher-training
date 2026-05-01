# frozen_string_literal: true

require "rails_helper"

describe CourseSchools::Creator do
  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }
  let(:gias_school) { create(:gias_school) }

  context "when the provider has a matching Provider::School" do
    let!(:provider_school) do
      create(:provider_school, provider:, gias_school:, site_code: "Q")
    end

    it "creates a Course::School row for the course and gias_school" do
      expect {
        described_class.call(course:, gias_school_id: gias_school.id)
      }.to change(Course::School, :count).by(1)

      row = Course::School.last
      expect(row.course).to eq(course)
      expect(row.gias_school_id).to eq(gias_school.id)
    end

    it "copies site_code from the matching Provider::School" do
      result = described_class.call(course:, gias_school_id: gias_school.id)

      expect(result.site_code).to eq("Q")
    end

    it "returns the created row" do
      result = described_class.call(course:, gias_school_id: gias_school.id)

      expect(result).to be_a(Course::School)
      expect(result).to be_persisted
    end

    it "is idempotent when called twice with the same course and gias_school" do
      described_class.call(course:, gias_school_id: gias_school.id)

      expect {
        described_class.call(course:, gias_school_id: gias_school.id)
      }.not_to change(Course::School, :count)
    end

    it "returns the existing row when one already exists for (course, gias_school)" do
      existing = create(:course_school, course:, gias_school:, site_code: "Q")

      result = described_class.call(course:, gias_school_id: gias_school.id)

      expect(result).to eq(existing)
    end

    it "returns the existing row when a RecordNotUnique race fires" do
      existing = create(:course_school, course:, gias_school:, site_code: "Q")

      schools_proxy = course.schools
      allow(course).to receive(:schools).and_return(schools_proxy)
      allow(schools_proxy).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordNotUnique)

      result = described_class.call(course:, gias_school_id: gias_school.id)

      expect(result).to eq(existing)
    end
  end

  context "when the provider has no matching Provider::School" do
    it "raises ActiveRecord::RecordNotFound" do
      expect {
        described_class.call(course:, gias_school_id: gias_school.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not create a Course::School row" do
      expect {
        described_class.call(course:, gias_school_id: gias_school.id)
      }.to raise_error(ActiveRecord::RecordNotFound).and(not_change(Course::School, :count))
    end
  end
end
