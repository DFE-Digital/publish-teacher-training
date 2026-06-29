# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params: {}) }

  # Find returns published courses only — never draft, rolled over or withdrawn —
  # and findability does not depend on whether a course has schools/sites
  # attached. The rule is exactly Course#is_published?.
  describe "findability is publication status, independent of site presence" do
    context "when a published course has a findable site" do
      let!(:course) do
        create(:course, :published, name: "Published With Site").tap do |c|
          create(:site_status, :findable, course: c)
        end
      end

      it "includes the course" do
        expect(results).to include(course)
      end
    end

    context "when a published course has only suspended sites" do
      let!(:course) do
        create(:course, :published, name: "Published Suspended Sites").tap do |c|
          create(:site_status, course: c, status: :suspended, publish: :published)
        end
      end

      it "includes the course (site status does not affect findability)" do
        expect(results).to include(course)
      end
    end

    context "when a published course has no sites at all" do
      let!(:course) { create(:course, :published, name: "Published No Sites") }

      it "includes the course" do
        expect(results).to include(course)
      end
    end

    context "when a draft course has a findable site" do
      let!(:course) do
        create(:course, name: "Draft With Site").tap do |c|
          create(:site_status, :findable, course: c)
        end
      end

      it "excludes the course (a findable site does not make an unpublished course findable)" do
        expect(results).not_to include(course)
      end
    end
  end

  describe "findability across enrichment states" do
    context "when the course is published" do
      let!(:course) { create(:course, :published, name: "Published") }

      it "includes the course" do
        expect(results).to include(course)
      end
    end

    context "when the course is draft only" do
      let!(:course) { create(:course, name: "Draft", enrichments: [build(:course_enrichment)]) }

      it "excludes the course" do
        expect(results).not_to include(course)
      end
    end

    context "when the course's latest enrichment is withdrawn" do
      let!(:course) { create(:course, name: "Withdrawn", enrichments: [build(:course_enrichment, :withdrawn)]) }

      it "excludes the course" do
        expect(results).not_to include(course)
      end
    end

    context "when the course's latest enrichment is rolled over" do
      let!(:course) { create(:course, name: "Rolled Over", enrichments: [build(:course_enrichment, :rolled_over)]) }

      it "excludes the course" do
        expect(results).not_to include(course)
      end
    end

    context "when the course has unpublished changes (a draft on top of a published enrichment)" do
      let!(:course) do
        create(:course, name: "Unpublished Changes",
                        enrichments: [
                          build(:course_enrichment, :published, created_at: 2.days.ago),
                          build(:course_enrichment, created_at: 1.day.ago),
                        ])
      end

      it "includes the course (it is still published)" do
        expect(results).to include(course)
      end
    end

    context "when a course was published and then withdrawn (a withdrawn enrichment on top of published history)" do
      let!(:course) do
        create(:course, name: "Published Then Withdrawn",
                        enrichments: [
                          build(:course_enrichment, :published, created_at: 2.days.ago),
                          build(:course_enrichment, :withdrawn, created_at: 1.day.ago),
                        ])
      end

      it "excludes the course (the latest enrichment is withdrawn)" do
        expect(results).not_to include(course)
      end
    end

    context "when a course was published, edited and republished several times, then withdrawn" do
      let!(:course) do
        create(:course, name: "Republished Then Withdrawn",
                        enrichments: [
                          build(:course_enrichment, :published, created_at: 4.days.ago),
                          build(:course_enrichment, :published, created_at: 3.days.ago),
                          build(:course_enrichment, :withdrawn, created_at: 1.day.ago),
                        ])
      end

      it "excludes the course (publication history does not matter once the latest enrichment is withdrawn)" do
        expect(results).not_to include(course)
      end
    end

    context "when a rolled over enrichment sits on top of a published one" do
      let!(:course) do
        create(:course, name: "Rolled Over On Published",
                        enrichments: [
                          build(:course_enrichment, :published, created_at: 2.days.ago),
                          build(:course_enrichment, :rolled_over, created_at: 1.day.ago),
                        ])
      end

      it "excludes the course (the latest enrichment is rolled over)" do
        expect(results).not_to include(course)
      end
    end
  end
end
