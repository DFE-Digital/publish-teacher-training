# frozen_string_literal: true

require "rails_helper"

module Exports
  describe AccreditedCourseList do
    subject(:export) { described_class.new(courses: accreditor.current_accredited_courses) }

    let(:accreditor) { create(:accredited_provider) }
    let(:training_partner) { create(:provider, provider_name: "Partner University", provider_code: "1OJ") }

    def rows
      CSV.parse(export.data.delete_prefix(Exports::CourseColumns::BYTE_ORDER_MARK), headers: true)
    end

    def create_partner_course(*traits, **attributes)
      create(
        :course,
        *traits,
        provider: training_partner,
        accrediting_provider: accreditor,
        **attributes,
      )
    end

    describe "#data" do
      it "sets the correct row values" do
        create_partner_course(
          :secondary,
          :fee,
          :resulting_in_pgce_with_qts,
          name: "Design and technology",
          course_code: "K442",
          age_range_in_years: "11_to_16",
          study_mode: :full_time,
          start_date: Time.zone.local(training_partner.recruitment_cycle_year.to_i, 9, 1),
          site_statuses: [create(:site_status, :full_time_vacancies, :findable, site: create(:site, code: "K"))],
          enrichments: [build(:course_enrichment, :published, course_length: "OneYear", fee_uk_eu: 9_535, fee_international: 21_500)],
        )

        expect(rows.first.to_h).to eq(
          "Provider" => "Partner University",
          "Provider code" => "1OJ",
          "Course name" => "Design and technology",
          "Course code" => "K442",
          "Status" => "Published",
          "Age range" => "11 to 16",
          "Fee or salary" => "Fee-paying",
          "Qualification" => "QTS with PGCE",
          "Full time or part time" => "Full time",
          "Start date" => "September #{training_partner.recruitment_cycle_year}",
          "Course length" => "1 year",
          "UK fee" => "£9,535",
          "Non-UK fee" => "£21,500",
          "View on Find" => "http://find.localhost/course/1OJ/K442",
          "Campus codes" => "K",
        )
      end

      it "leads with the byte order mark so Excel reads the fee columns as UTF-8" do
        create_partner_course(:fee, enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9_535)])

        expect(export.data).to start_with(Exports::CourseColumns::BYTE_ORDER_MARK)
      end

      it "reports a rolled-over course's own status and fees, which the model counts as draft" do
        create_partner_course(:fee, enrichments: [
          build(:course_enrichment, :rolled_over, fee_uk_eu: 9_000, course_length: "OneYear"),
        ])

        expect(rows.first.to_h).to include(
          "Status" => "Rolled over", "UK fee" => "£9,000", "Course length" => "1 year",
        )
      end

      it "lists campus codes in a stable order, whatever order the sites load in" do
        create_partner_course(site_statuses: [
          create(:site_status, :findable, site: create(:site, code: "M")),
          create(:site_status, :findable, site: create(:site, code: "A")),
          create(:site_status, :findable, site: create(:site, code: "8")),
        ])

        expect(rows.first["Campus codes"]).to eq("8 A M")
      end

      it "lists the main site code last so Excel does not read the cell as a formula" do
        create_partner_course(site_statuses: [
          create(:site_status, :findable, site: create(:site, code: Provider::School::MAIN_SITE_CODE)),
          create(:site_status, :findable, site: create(:site, code: "F")),
        ])

        expect(rows.first["Campus codes"]).to eq("F -")
      end

      it "leaves the enrichment columns empty when there is no enrichment" do
        create_partner_course(:salary)

        expect(rows.first.to_h).to include(
          "Status" => "Draft", "Course length" => nil, "UK fee" => nil, "Non-UK fee" => nil,
        )
      end
    end
  end
end
