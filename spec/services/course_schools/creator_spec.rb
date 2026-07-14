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

    it "creates a Course::School row for the course and provider_school" do
      expect {
        described_class.call(course:, provider_school:)
      }.to change(Course::School, :count).by(1)

      row = Course::School.last
      expect(row.course).to eq(course)
      expect(row.gias_school_id).to eq(gias_school.id)
      expect(row.provider_school).to eq(provider_school)
    end

    it "links the row to the matching Provider::School" do
      result = described_class.call(course:, provider_school_id: provider_school.id)

      expect(result.provider_school).to eq(provider_school)
    end

    it "can resolve the provider school by gias_school_id and site_code" do
      main_site_provider_school = create(:provider_school, :main_site, provider:, gias_school:)

      result = described_class.call(course:, gias_school_id: gias_school.id, site_code: "Q")

      expect(result.provider_school).to eq(provider_school)
      expect(result.provider_school).not_to eq(main_site_provider_school)
    end

    it "returns the created row" do
      result = described_class.call(course:, provider_school:)

      expect(result).to be_a(Course::School)
      expect(result).to be_persisted
    end

    it "is idempotent when called twice with the same course and provider_school" do
      described_class.call(course:, provider_school:)

      expect {
        described_class.call(course:, provider_school:)
      }.not_to change(Course::School, :count)
    end

    it "returns the existing row when one already exists for (course, provider_school)" do
      existing = create(:course_school, course:, gias_school:, provider_school:, site_code: "Q")

      result = described_class.call(course:, provider_school:)

      expect(result).to eq(existing)
    end

    it "returns the existing row when a RecordNotUnique race fires" do
      existing = create(:course_school, course:, gias_school:, provider_school:, site_code: "Q")

      schools_proxy = course.schools
      allow(course).to receive(:schools).and_return(schools_proxy)
      allow(schools_proxy).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordNotUnique)

      result = described_class.call(course:, provider_school:)

      expect(result).to eq(existing)
    end
  end

  context "when the provider has no matching Provider::School" do
    it "logs and skips when only gias_school_id is supplied" do
      expect(Rails.logger).to receive(:warn).with(/ArgumentError/)

      expect(described_class.call(course:, gias_school_id: gias_school.id)).to be_nil
    end

    it "logs and skips when the provider_school row is missing" do
      expect(Rails.logger).to receive(:warn).with(/ActiveRecord::RecordNotFound/)

      expect(described_class.call(course:, provider_school_id: Provider::School.maximum(:id).to_i + 1_000)).to be_nil
    end

    it "does not create a Course::School row" do
      expect {
        described_class.call(course:, provider_school_id: Provider::School.maximum(:id).to_i + 1_000)
      }.not_to change(Course::School, :count)
    end
  end
end
