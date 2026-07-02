# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params: {}) }

  # Salaried/apprenticeship courses that support has approved to publish without
  # an employing school have no running, published site. They are findable on
  # exactly the same terms as every other course: they must be published.
  # Neither school presence nor the publish_without_schools_allowed flag affects
  # findability — only publication does.
  describe "findability of courses without a school" do
    context "when a published salaried course has no schools" do
      let!(:course) do
        create(:course, :with_salary, :published, publish_without_schools_allowed: true, name: "Salary School-less")
      end

      it "includes the course" do
        expect(results).to include(course)
      end
    end

    context "when a published apprenticeship course has no schools" do
      let!(:course) do
        create(:course, :with_apprenticeship, :published, publish_without_schools_allowed: true, name: "Apprenticeship School-less")
      end

      it "includes the course" do
        expect(results).to include(course)
      end
    end

    context "when a published course only has study sites (no employing school)" do
      let!(:course) do
        create(:course, :with_salary, :published, publish_without_schools_allowed: true, study_sites: [build(:site, :study_site)])
      end

      it "includes the course" do
        expect(results).to include(course)
      end
    end

    context "when a published fee course has no schools" do
      let!(:course) { create(:course, :fee, :published, name: "Fee School-less") }

      it "includes the course (publication, not the exemption flag, drives findability)" do
        expect(results).to include(course)
      end
    end

    context "when a published salaried course has no schools and is not flagged publish_without_schools_allowed" do
      let!(:course) do
        create(:course, :with_salary, :published, publish_without_schools_allowed: false, name: "Salary Not Flagged")
      end

      it "includes the course (the flag does not affect findability)" do
        expect(results).to include(course)
      end
    end

    context "when a school-less salaried course is not published (draft only)" do
      let!(:course) do
        create(:course, :with_salary, publish_without_schools_allowed: true, name: "Salary Draft",
                                      enrichments: [build(:course_enrichment)])
      end

      it "excludes the course (it is not published)" do
        expect(results).not_to include(course)
      end
    end

    context "when the result set mixes a school-less course and a course with a findable site" do
      let!(:school_less_course) do
        create(:course, :with_salary, :published, publish_without_schools_allowed: true, name: "School-less")
      end
      let!(:course_with_site) do
        create(:course, :published, name: "With Site").tap do |c|
          create(:site_status, :findable, course: c)
        end
      end

      it "includes both" do
        expect(results).to include(school_less_course, course_with_site)
      end

      it "counts each course exactly once" do
        expect(described_class.new(params: {}).count).to eq(2)
      end
    end
  end
end
