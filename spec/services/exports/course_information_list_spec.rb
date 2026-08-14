# frozen_string_literal: true

require "rails_helper"

module Exports
  describe CourseInformationList do
    subject(:export) { described_class.new(provider: provider.reload) }

    let(:provider) { create(:provider) }

    def rows
      CSV.parse(export.data, headers: true)
    end

    describe "#data" do
      it "sets the correct row values" do
        create(
          :course,
          :secondary,
          :fee,
          :resulting_in_pgce_with_qts,
          provider:,
          name: "Chemistry",
          course_code: "2KGZ",
          age_range_in_years: "11_to_16",
          study_mode: :full_time_or_part_time,
          start_date: Time.zone.local(provider.recruitment_cycle_year.to_i, 9, 1),
          enrichments: [build(:course_enrichment, :published, course_length: "OneYear", fee_uk_eu: 9_790, fee_international: 15_000)],
        )

        expect(rows.first.to_h).to eq(
          "Course name" => "Chemistry",
          "Course code" => "2KGZ",
          "Accredited provider" => provider.provider_name,
          "Status" => "Closed",
          "Age range" => "11 to 16",
          "Fee or salary" => "Fee-paying",
          "Qualification" => "QTS with PGCE",
          "Study mode" => "Full time or part time",
          "Start date" => "September #{provider.recruitment_cycle_year}",
          "Course length" => "1 year",
          "UK fee" => "£9,790",
          "Non-UK fee" => "£15,000",
        )
      end

      it "leaves the enrichment columns empty when there is no enrichment" do
        create(:course, :salary, provider:, name: "Physical Education")

        expect(rows.first.to_h).to include(
          "Course length" => nil, "UK fee" => nil, "Non-UK fee" => nil, "Status" => "Draft",
        )
      end

      it "names the ratifying provider, in the order the course list page shows them" do
        other = create(:accredited_provider, provider_name: "University of Brighton")
        create(:course, provider:, accrediting_provider: other, name: "Ratified course")
        create(:course, provider:, accrediting_provider: nil, name: "Own course")

        expect(rows.map { |row| row.values_at("Course name", "Accredited provider") }).to eq(
          [
            ["Own course", provider.provider_name],
            ["Ratified course", "University of Brighton"],
          ],
        )
      end
    end

    describe "#filename" do
      it "carries the provider code and the date" do
        expect(export.filename).to eq("course-information-#{provider.provider_code}-#{Time.zone.today}.csv")
      end
    end
  end
end
