# frozen_string_literal: true

require "rails_helper"

module Find
  module Courses
    module SummaryComponent
      describe View do
        it "renders sub sections" do
          provider = build(:provider).decorate
          course = create(:course, :fee, :draft_enrichment, applications_open_from: Time.zone.tomorrow, provider:).decorate
          enrichment = course.latest_draft_enrichment

          result = render_inline(described_class.new(course, enrichment))
          expect(result.text).to include(
            "Fee or salary",
            "Course length",
            "Age group",
            "Qualification awarded",
            "Provider",
            "Start date",
          )
        end

        context "when teacher degree apprenticeship course has incorrect fees" do
          it "does not render fees" do
            enrichment = create(:course_enrichment, fee_uk_eu: 9250)
            course = create(:course, :apprenticeship, :published_teacher_degree_apprenticeship, enrichments: [enrichment]).decorate

            result = render_inline(described_class.new(course, enrichment))
            expect(result.text).not_to include("£9,250")
            expect(result.text).to include("Fee or salary")
            expect(result.text).to include("Salary (apprenticeship)")
          end
        end

        context "a course has an accrediting provider that is not the provider" do
          it "renders the accredited provider" do
            enrichment = create(:course_enrichment)
            course = create(:course, enrichments: [enrichment], provider: build(:provider), accrediting_provider: build(:provider)).decorate

            result = render_inline(described_class.new(course, enrichment))

            expect(result.text).to include(
              "Accredited by",
            )
          end
        end

        context "the course provider and accrediting provider are the same" do
          it "does not render the accredited provider" do
            enrichment = create(:course_enrichment)
            provider = create(:provider)

            course = create(:course, enrichments: [enrichment], provider:, accrediting_provider: provider).decorate

            result = render_inline(described_class.new(course, enrichment))

            expect(result.text).not_to include(
              "Accredited provider",
            )
          end
        end

        context "secondary course" do
          it "renders the age range and level" do
            enrichment = create(:course_enrichment)
            course = create(:course, :secondary, enrichments: [enrichment], provider: build(:provider)).decorate

            result = render_inline(described_class.new(course, enrichment))

            expect(result.text).to include("11 to 18 - secondary")
          end
        end

        context "non-secondary course" do
          it "render the age range only" do
            enrichment = create(:course_enrichment)
            course = create(:course, enrichments: [enrichment], provider: build(:provider)).decorate

            result = render_inline(described_class.new(course, enrichment))

            expect(result.text).to include("3 to 7")
          end
        end

        describe "#incentive_hint" do
          before { FeatureFlag.activate(:bursaries_and_scholarships_announced) }
          after { FeatureFlag.deactivate(:bursaries_and_scholarships_announced) }

          context "when the subject has a bursary" do
            it "shows the bursary hint" do
              subject = build(:secondary_subject, :dance, bursary_amount: 9000)
              enrichment = create(:course_enrichment, :published)
              course = create(:course, :secondary, :fee_type_based, subjects: [subject], enrichments: [enrichment]).decorate

              result = render_inline(described_class.new(course, enrichment))
              expect(result.text).to include("Bursaries of £9,000 are available")
            end
          end

          context "when the subject has a bursary and scholarship" do
            it "shows both" do
              subject = build(:secondary_subject, :chemistry, bursary_amount: 20_000, scholarship: 22_000)
              enrichment = create(:course_enrichment, :published)
              course = create(:course, :secondary, :fee_type_based, subjects: [subject], enrichments: [enrichment]).decorate

              result = render_inline(described_class.new(course, enrichment))
              expect(result.text).to include("Scholarships of £22,000 or bursaries of £20,000 are available")
            end
          end

          context "when the course is salaried" do
            it "does not show bursaries" do
              subject = build(:secondary_subject, :dance, bursary_amount: 9000)
              enrichment = create(:course_enrichment, :published)
              course = create(:course, :secondary, :salary, subjects: [subject], enrichments: [enrichment]).decorate

              result = render_inline(described_class.new(course, enrichment))
              expect(result.text).not_to include("Bursaries")
            end
          end

          context "when the feature flag is inactive" do
            before { FeatureFlag.deactivate(:bursaries_and_scholarships_announced) }

            it "does not show bursaries" do
              subject = build(:secondary_subject, :dance, bursary_amount: 9000)
              enrichment = create(:course_enrichment, :published)
              course = create(:course, :secondary, :fee_type_based, subjects: [subject], enrichments: [enrichment]).decorate

              result = render_inline(described_class.new(course, enrichment))
              expect(result.text).not_to include("Bursaries")
            end
          end

          context "when the subject is not non-UK eligible" do
            it "appends 'for UK citizens'" do
              subject = build(:secondary_subject, :chemistry, bursary_amount: 20_000)
              enrichment = create(:course_enrichment, :published)
              course = create(:course, :secondary, :fee_type_based, subjects: [subject], enrichments: [enrichment]).decorate

              result = render_inline(described_class.new(course, enrichment))
              expect(result.text).to include("for UK citizens")
            end
          end
        end

        context "when there are UK fees" do
          it "renders the uk fees" do
            enrichment = create(:course_enrichment, fee_uk_eu: 9250)
            course = create(:course, :fee, enrichments: [enrichment]).decorate

            result = render_inline(described_class.new(course, enrichment))
            expect(result.text).to include("Fee or salary")
            expect(result.text).to include("£9,250 fee for UK citizens")
          end
        end

        context "when there are international fees" do
          it "renders the international fees" do
            enrichment = create(:course_enrichment, fee_international: 14_000)
            course = create(:course, :fee, enrichments: [enrichment]).decorate

            result = render_inline(described_class.new(course, enrichment))
            expect(result.text).to include("£14,000 fee for Non-UK citizens")
          end
        end

        context "when there are uk fees but no international fees" do
          it "renders the uk fees and not the international fee label" do
            enrichment = create(:course_enrichment, fee_uk_eu: 9250, fee_international: nil)
            course = create(:course, :fee, enrichments: [enrichment]).decorate

            result = render_inline(described_class.new(course, enrichment))

            expect(result.text).to include("£9,250 fee for UK citizens")
            expect(result.text).not_to include("fee for Non-UK citizens")
          end
        end

        context "when there are international fees but no uk fees" do
          it "renders the international fees but not the uk fee label" do
            enrichment = create(:course_enrichment, fee_uk_eu: nil, fee_international: 14_000)
            course = create(:course, :fee, enrichments: [enrichment]).decorate

            result = render_inline(described_class.new(course, enrichment))

            expect(result.text).not_to include("fee for UK citizens")
            expect(result.text).to include("£14,000 fee for Non-UK citizens")
          end
        end

        context "when there are no fees" do
          it "does not render the row" do
            enrichment = create(:course_enrichment, fee_uk_eu: nil, fee_international: nil)
            course = create(:course, :salary, enrichments: [enrichment]).decorate

            result = render_inline(described_class.new(course, enrichment))

            expect(result.text).not_to include("for UK citizens")
            expect(result.text).not_to include("£14,000 for Non-UK citizens")
            expect(result.text).to include("Fee or salary")
          end
        end
      end
    end
  end
end
