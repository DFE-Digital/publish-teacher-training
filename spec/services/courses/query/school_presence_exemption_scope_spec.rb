# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params: {}) }

  # Salaried/apprenticeship courses that support has approved to publish without
  # an employing school have no running, published site, so the legacy
  # findability check excludes them. Under the new school model flag they should
  # instead be findable when they are exempt and their latest enrichment is
  # published (mirroring Course#is_published? so they never 404 on the show page).
  describe "school presence exemption findability" do
    let(:exempt_salary_course) do
      create(:course, :with_salary, :published, publish_without_schools_allowed: true, name: "Exempt Salary")
    end

    context "when the new school model flag is active" do
      before { FeatureFlag.activate(:course_publishing_uses_new_school_model) }

      context "when an exempt salaried course is published without sites or schools" do
        let!(:course) { exempt_salary_course }

        it "includes the course" do
          expect(results).to include(course)
        end
      end

      context "when an exempt apprenticeship course is published without sites or schools" do
        let!(:course) do
          create(:course, :with_apprenticeship, :published, publish_without_schools_allowed: true, name: "Exempt Apprenticeship")
        end

        it "includes the course" do
          expect(results).to include(course)
        end
      end

      context "when the exempt course only has study sites (no employing school)" do
        let!(:course) do
          create(:course, :with_salary, :published, publish_without_schools_allowed: true, study_sites: [build(:site, :study_site)])
        end

        it "includes the course" do
          expect(results).to include(course)
        end
      end

      context "when a fee course is flagged publish_without_schools_allowed without sites" do
        let!(:course) do
          create(:course, :fee, :published, publish_without_schools_allowed: true, name: "Fee No Schools")
        end

        it "excludes the course (fee courses are never exempt)" do
          expect(results).not_to include(course)
        end
      end

      context "when a salaried course is not flagged publish_without_schools_allowed" do
        let!(:course) do
          create(:course, :with_salary, :published, publish_without_schools_allowed: false, name: "Salary Not Flagged")
        end

        it "excludes the course" do
          expect(results).not_to include(course)
        end
      end

      context "when an exempt salaried course has no published enrichment (draft only)" do
        let!(:course) do
          create(:course, :with_salary, publish_without_schools_allowed: true, name: "Salary Draft",
                                        enrichments: [build(:course_enrichment)])
        end

        it "excludes the course" do
          expect(results).not_to include(course)
        end
      end

      context "when an exempt salaried course's latest enrichment is withdrawn" do
        let!(:course) do
          create(:course, :with_salary, publish_without_schools_allowed: true, name: "Salary Withdrawn",
                                        enrichments: [build(:course_enrichment, :withdrawn)])
        end

        it "excludes the course" do
          expect(results).not_to include(course)
        end
      end

      context "when an exempt salaried course's latest enrichment is rolled over on top of a published one" do
        let!(:course) do
          create(:course, :with_salary, publish_without_schools_allowed: true, name: "Salary Rolled Over",
                                        enrichments: [
                                          build(:course_enrichment, :published, created_at: 2.days.ago),
                                          build(:course_enrichment, :rolled_over, created_at: 1.day.ago),
                                        ])
        end

        it "excludes the course (the latest enrichment is not published)" do
          expect(results).not_to include(course)
        end
      end

      context "when the result set also contains a normal fee course with a findable site" do
        let!(:exempt_course) { exempt_salary_course }
        let!(:fee_course) do
          create(:course, :published, name: "Fee With Site").tap do |c|
            create(:site_status, :findable, course: c)
          end
        end

        it "includes both (the exemption widens findability, it does not replace it)" do
          expect(results).to include(exempt_course, fee_course)
        end

        it "counts each findable course exactly once" do
          expect(described_class.new(params: {}).count).to eq(2)
        end
      end
    end

    context "when the new school model flag is inactive" do
      context "when an exempt salaried course is published without sites or schools" do
        let!(:course) { exempt_salary_course }

        it "excludes the course (the exemption only exists under the flag)" do
          expect(results).not_to include(course)
        end
      end

      context "when a course has a findable site" do
        let!(:course) do
          create(:course, :published, name: "Fee With Site").tap do |c|
            create(:site_status, :findable, course: c)
          end
        end

        it "is still included (legacy behaviour unchanged)" do
          expect(results).to include(course)
        end
      end

      it "produces the same findability SQL as before, with no exemption branch" do
        sql = described_class.new(params: {}).scope.to_sql

        expect(sql).to include("course_site.publish = 'Y'")
        expect(sql).not_to include("publish_without_schools_allowed")
      end
    end
  end
end
