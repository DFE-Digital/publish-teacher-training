# frozen_string_literal: true

require "rails_helper"

describe API::Public::V1::SchoolLocationStatus do
  subject(:location_status) { described_class.new(course_school) }

  let(:course_school) { create(:course_school, course:) }

  describe "#id" do
    let(:course) { create(:course) }

    it "returns the course school id" do
      expect(location_status.id).to eq(course_school.id)
    end
  end

  describe "#status" do
    let(:course) { create(:course) }

    it "is always running" do
      expect(location_status.status).to eq("running")
    end
  end

  describe "#publish" do
    let(:course) { create(:course) }

    it "is always published" do
      expect(location_status.publish).to eq("published")
    end
  end

  describe "#has_vacancies?" do
    let(:course) { create(:course) }

    it "is always true" do
      expect(location_status.has_vacancies?).to be(true)
    end
  end

  describe "#vac_status" do
    context "when the course is full time" do
      let(:course) { create(:course, study_mode: "full_time") }

      it "returns full time vacancies" do
        expect(location_status.vac_status).to eq("full_time_vacancies")
      end
    end

    context "when the course is part time" do
      let(:course) { create(:course, study_mode: "part_time") }

      it "returns part time vacancies" do
        expect(location_status.vac_status).to eq("part_time_vacancies")
      end
    end

    context "when the course is full time or part time" do
      let(:course) { create(:course, study_mode: "full_time_or_part_time") }

      it "returns both full time and part time vacancies" do
        expect(location_status.vac_status).to eq("both_full_time_and_part_time_vacancies")
      end
    end
  end
end
