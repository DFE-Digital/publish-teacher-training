# frozen_string_literal: true

require "rails_helper"

describe CourseSchools::Creator do
  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }
  let(:gias_school) { create(:gias_school) }
  let!(:provider_school) do
    create(:provider_school, provider:, gias_school:, site_code: "Q")
  end

  it "creates a Course::School row for the course and provider_school" do
    expect {
      described_class.call(course:, provider_school:)
    }.to change(Course::School, :count).by(1)

    row = Course::School.last
    expect(row.course).to eq(course)
    expect(row.provider_school).to eq(provider_school)
  end

  it "copies gias_school_id from the provider_school" do
    result = described_class.call(course:, provider_school:)

    expect(result.gias_school_id).to eq(provider_school.gias_school_id)
  end

  it "exposes the provider_school's site_code" do
    result = described_class.call(course:, provider_school:)

    expect(result.site_code).to eq("Q")
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

  it "returns the existing row when one already exists" do
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

  # provider_school's unique index is (provider_id, gias_school_id, site_code),
  # so a provider may legitimately hold the same GIAS school twice. Keying on
  # gias_school_id used to pick between them arbitrarily.
  context "when the provider holds the same gias_school under two site_codes" do
    let!(:other_provider_school) do
      create(:provider_school, provider:, gias_school:, site_code: "R")
    end

    it "attaches the provider_school it was given, not the other one" do
      result = described_class.call(course:, provider_school: other_provider_school)

      expect(result.provider_school).to eq(other_provider_school)
      expect(course.schools.reload.map(&:provider_school)).to contain_exactly(other_provider_school)
    end

    it "lets both be attached to the same course" do
      described_class.call(course:, provider_school:)
      described_class.call(course:, provider_school: other_provider_school)

      expect(course.schools.reload.map(&:provider_school))
        .to contain_exactly(provider_school, other_provider_school)
    end
  end

  context "when the provider_school belongs to another provider" do
    let(:other_provider_school) { create(:provider_school, gias_school:) }

    it "raises rather than writing a row that fails the consistency check" do
      expect {
        described_class.call(course:, provider_school: other_provider_school)
      }.to raise_error(ActiveRecord::RecordInvalid).and(not_change(Course::School, :count))
    end
  end
end
