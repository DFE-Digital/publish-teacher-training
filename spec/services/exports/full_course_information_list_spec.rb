# frozen_string_literal: true

require "rails_helper"

module Exports
  describe FullCourseInformationList do
    subject(:export) { described_class.new(provider: provider.reload) }

    let(:provider) { create(:provider) }

    def rows
      CSV.parse(export.data.delete_prefix(Exports::CourseColumns::BYTE_ORDER_MARK), headers: true)
    end

    describe "#data" do
      it "heads each text column with the question the provider answers in Publish" do
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
          enrichments: [build(
            :course_enrichment,
            :published,
            course_length: "OneYear",
            fee_uk_eu: 9_790,
            fee_international: 15_000,
            fee_schedule: "Paid in three instalments.",
            additional_fees: "A £50 DBS check.",
            financial_support: "Bursaries are available.",
            salary_details: "Paid as an unqualified teacher.",
            placement_selection_criteria: "We match on travel time.",
            duration_per_school: "Two terms in each school.",
            theoretical_training_location: "At our Frenchay campus.",
            theoretical_training_duration: "One day a week.",
            placement_school_activities: "You will teach a reduced timetable.",
            support_and_mentorship: "A school mentor meets you weekly.",
            theoretical_training_activities: "Seminars on pedagogy.",
            assessment_methods: "Two written assignments.",
            interview_process: "A subject knowledge task and an interview.",
            interview_location: "both",
          )],
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
          "When are the fees due? Is there a payment schedule? (optional)" => "Paid in three instalments.",
          "Are there any additional fees or costs? (optional)" => "A £50 DBS check.",
          "Does your organisation offer any financial support? (optional)" => "Bursaries are available.",
          "Salary" => "Paid as an unqualified teacher.",
          "How do you decide which schools to place trainees in?" => "We match on travel time.",
          "How much time will they spend in each school?" => "Two terms in each school.",
          "Where will theoretical training take place? (optional)" => "At our Frenchay campus.",
          "How much time will they spend in theoretical training? (optional)" => "One day a week.",
          "What will trainees do while in their placement schools?" => "You will teach a reduced timetable.",
          "How will they be supported and mentored? (optional)" => "A school mentor meets you weekly.",
          "What will trainees do during their theoretical training?" => "Seminars on pedagogy.",
          "How will they be assessed? (optional)" => "Two written assignments.",
          "What is the interview process? (optional)" => "A subject knowledge task and an interview.",
          "Where will the interviews take place? (optional)" => "Either in person or online",
        )
      end

      it "reports an unpublished edit rather than the text published beneath it" do
        create(:course, :fee, provider:, name: "Chemistry", enrichments: [
          build(:course_enrichment, :published, interview_process: "The published interview process."),
          build(:course_enrichment, :subsequent_draft, interview_process: "The edited interview process."),
        ])

        expect(rows.first.to_h).to include("What is the interview process? (optional)" => "The edited interview process.")
      end

      it "leaves the text columns empty when a course has no enrichment" do
        create(:course, :fee, provider:, name: "Physical Education")

        expect(rows.first.to_h).to include(
          "Status" => "Draft",
          "When are the fees due? Is there a payment schedule? (optional)" => nil,
          "How do you decide which schools to place trainees in?" => nil,
          "What is the interview process? (optional)" => nil,
          "Where will the interviews take place? (optional)" => nil,
        )
      end

      it "exports the text as markdown, so it can be pasted back into Publish" do
        create(:course, :fee, provider:, name: "Biology", enrichments: [
          build(:course_enrichment, :published, placement_school_activities: "You will:\n\n- teach\n- observe"),
        ])

        expect(rows.first["What will trainees do while in their placement schools?"]).to eq("You will:\n\n- teach\n- observe")
      end

      it "leaves the fees empty for a course that charges none, whatever the enrichment holds" do
        create(:course, :apprenticeship, provider:, name: "Apprenticeship course", enrichments: [
          build(:course_enrichment, :published, fee_uk_eu: 9_790, fee_international: 15_000),
        ])
        create(:course, :salary, provider:, name: "Salaried course", enrichments: [
          build(:course_enrichment, :published, fee_uk_eu: 9_790, fee_international: 15_000),
        ])

        expect(rows.map { |row| row.values_at("Course name", "UK fee", "Non-UK fee") }).to eq(
          [
            ["Apprenticeship course", nil, nil],
            ["Salaried course", nil, nil],
          ],
        )
      end

      it "omits school experience, which no course in the cycle can be asked for" do
        create(:course, :salary, provider:, name: "Chemistry")

        expect(rows.headers).not_to include("What school experience are you looking for?")
      end

      context "when the cycle takes fees rather than salary details" do
        let(:provider) { create(:provider, :next_recruitment_cycle) }

        it "heads the column with the question that replaced salary details" do
          create(:course, :salary, provider:, name: "Chemistry", enrichments: [
            build(:course_enrichment, :published, salary_fee_details: "There are no fees to pay."),
          ])

          expect(rows.first.to_h).to include(
            "Give details about any fees or other costs that the trainee might have to pay (optional)" => "There are no fees to pay.",
          )
          expect(rows.headers).not_to include("Salary")
        end

        it "carries the school experience a salaried course asks for" do
          create(:course, :salary, provider:, name: "Chemistry",
                                   school_experience_required: true,
                                   school_experience_required_content: "Spend two weeks in a secondary school.")

          expect(rows.first.to_h).to include("What school experience are you looking for?" => "Spend two weeks in a secondary school.")
        end

        it "says so when a salaried course asks for no school experience" do
          create(:course, :salary, provider:, name: "Biology", school_experience_required: false)

          expect(rows.first.to_h).to include("What school experience are you looking for?" => "Not required")
        end

        it "leaves school experience empty for a course that is never asked the question" do
          create(:course, :fee, provider:, name: "Physics")

          expect(rows.first.to_h).to include("What school experience are you looking for?" => nil)
        end
      end
    end

    describe "#filename" do
      it "carries the provider code and the date" do
        expect(export.filename).to eq("full-course-information-#{provider.provider_code}-#{Time.zone.today}.csv")
      end
    end
  end
end
