# frozen_string_literal: true

require "rails_helper"

module Exports
  describe CourseSchoolsList do
    subject(:export) { described_class.new(provider: provider.reload) }

    let(:provider) { create(:provider) }

    def rows
      CSV.parse(export.data.delete_prefix(Exports::CourseColumns::BYTE_ORDER_MARK), headers: true)
    end

    def course_at(*args, **attributes)
      traits, school_names = args.partition { |arg| arg.is_a?(Symbol) }
      course = create(:course, *traits, provider:, accrediting_provider: nil, **attributes)
      school_names.each do |name|
        create(:course_school, course:, gias_school: create(:gias_school, name:))
      end
      course
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

      it "lists a school once per course even when attached twice" do
        course = course_at(name: "Doubly attached")
        school = create(:gias_school, name: "Admirals Academy")
        create_list(:course_school, 2, course:, gias_school: school)

        expect(rows.map { |row| row["Placement schools"] }).to eq(["Admirals Academy"])
      end

      it "keeps two different schools that share a name" do
        course = course_at(name: "Same name twice")
        create(:course_school, course:, gias_school: create(:gias_school, name: "Thameside Primary School", urn: "109800"))
        create(:course_school, course:, gias_school: create(:gias_school, name: "Thameside Primary School", urn: "138581"))

        expect(rows.map { |row| row["Placement schools"] }).to eq(["Thameside Primary School", "Thameside Primary School"])
      end

      it "names the school as GIAS does, not as the legacy site does" do
        course = course_at(name: "Renamed school")
        gias_school = create(:gias_school, name: "Orion Coopers")
        site = create(:site, provider:, location_name: "Coopers School")
        create(:course_school, course:, gias_school:)
        create(:site_status, :running, course:, site:)

        expect(rows.map { |row| row["Placement schools"] }).to eq(["Orion Coopers"])
      end

      it "leaves out a course with no school attached" do
        course_at("Admirals Academy", name: "Attached course")
        create(:course, provider:, accrediting_provider: nil, name: "Unattached course")

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
