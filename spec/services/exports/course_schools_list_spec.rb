# frozen_string_literal: true

require "rails_helper"

module Exports
  describe CourseSchoolsList do
    subject(:export) { described_class.new(provider: provider.reload) }

    let(:provider) { create(:provider) }

    def rows
      CSV.parse(export.data, headers: true)
    end

    def course_at(*school_names, **attributes)
      create(
        :course,
        provider:,
        accrediting_provider: nil,
        site_statuses: school_names.map { |name| build(:site_status, :running, site: create(:site, provider:, location_name: name)) },
        **attributes,
      )
    end

    describe "#data" do
      it "sets the correct row values" do
        course_at(
          "Admirals Academy",
          :secondary,
          name: "Art and design",
          course_code: "F339",
          age_range_in_years: "11_to_16",
        )

        expect(rows.first.to_h).to eq(
          "Placement schools" => "Admirals Academy",
          "Course name" => "Art and design",
          "Course code" => "F339",
          "Status" => "Draft",
          "Age range" => "11 to 16",
        )
      end

      it "repeats a course once per school it is attached to" do
        course_at("Alde Valley Academy", "Admirals Academy", "Ashleigh Primary School", name: "Modern Languages")

        expect(rows.map { |row| row.values_at("Placement schools", "Course name") }).to eq(
          [
            ["Admirals Academy", "Modern Languages"],
            ["Alde Valley Academy", "Modern Languages"],
            ["Ashleigh Primary School", "Modern Languages"],
          ],
        )
      end

      it "orders by school and then by course" do
        course_at("Alde Valley Academy", "Admirals Academy", name: "Modern Languages")
        course_at("Admirals Academy", name: "Art and design")
        course_at("Alde Valley Academy", name: "Geography")

        expect(rows.map { |row| row.values_at("Placement schools", "Course name") }).to eq(
          [
            ["Admirals Academy", "Art and design"],
            ["Admirals Academy", "Modern Languages"],
            ["Alde Valley Academy", "Geography"],
            ["Alde Valley Academy", "Modern Languages"],
          ],
        )
      end

      it "orders same-named courses at one school by course code" do
        course_at("Admirals Academy", name: "Primary", course_code: "S909")
        course_at("Admirals Academy", name: "Primary", course_code: "2ZSC")
        course_at("Admirals Academy", name: "Primary", course_code: "R225")

        expect(rows.map { |row| row["Course code"] }).to eq(%w[2ZSC R225 S909])
      end

      it "leaves out a placement that is not running or new" do
        school = create(:site, provider:, location_name: "Admirals Academy")
        create(:course, provider:, accrediting_provider: nil, name: "Suspended placement",
                        site_statuses: [build(:site_status, :suspended, site: school)])

        expect(rows).to be_empty
      end

      it "lists a school once per course even when attached twice" do
        school = create(:site, provider:, location_name: "Admirals Academy")
        create(:course, provider:, accrediting_provider: nil, name: "Doubly attached",
                        site_statuses: [build(:site_status, :running, site: school),
                                        build(:site_status, :running, site: school)])

        expect(rows.map { |row| row["Placement schools"] }).to eq(["Admirals Academy"])
      end

      it "leaves out a course with no school attached" do
        course_at("Admirals Academy", name: "Attached course")
        create(:course, provider:, accrediting_provider: nil, name: "Unattached course", site_statuses: [])

        expect(rows.map { |row| row["Course name"] }).to eq(["Attached course"])
      end
    end

    describe "#filename" do
      it "carries the provider code and the date" do
        expect(export.filename).to eq("schools-attached-to-courses-#{provider.provider_code}-#{Time.zone.today}.csv")
      end
    end
  end
end
