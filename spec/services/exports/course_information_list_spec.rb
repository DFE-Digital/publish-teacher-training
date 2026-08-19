# frozen_string_literal: true

require "rails_helper"

module Exports
  describe CourseInformationList do
    subject(:export) { described_class.new(provider: provider.reload) }

    let(:provider) { create(:provider) }

    def rows
      CSV.parse(export.data.delete_prefix(Exports::CourseColumns::BYTE_ORDER_MARK), headers: true)
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

      it "reports the published fees, not an unpublished edit sitting over them" do
        create(:course, :fee, provider:, name: "Chemistry", enrichments: [
          build(:course_enrichment, :published, fee_uk_eu: 9_535, fee_international: 14_000),
          build(:course_enrichment, :initial_draft, fee_uk_eu: 9_790, fee_international: 15_000),
        ])

        expect(rows.first.to_h).to include("UK fee" => "£9,535", "Non-UK fee" => "£14,000")
      end

      it "keeps a withdrawn course's own values, since withdrawing leaves no published row" do
        create(:course, :fee, provider:, name: "Physics", enrichments: [
          build(:course_enrichment, :withdrawn, fee_uk_eu: 9_250),
        ])

        expect(rows.first.to_h).to include("Status" => "Withdrawn", "UK fee" => "£9,250")
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

      it "falls back to the code when the accrediting provider has no row in the cycle" do
        course = create(:course, provider:, accrediting_provider: nil, name: "Rolled over course")
        course.update_columns(accredited_provider_code: "ZZZ9")

        expect(rows.first.to_h).to include("Accredited provider" => "ZZZ9")
      end
    end

    describe "#filename" do
      it "carries the provider code and the date" do
        expect(export.filename).to eq("course-information-#{provider.provider_code}-#{Time.zone.today}.csv")
      end
    end
  end
end
