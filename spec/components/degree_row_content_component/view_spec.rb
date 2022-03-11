# frozen_string_literal: true

require "rails_helper"

module DegreeRowContentComponent
  describe View, type: :component do
    include Rails.application.routes.url_helpers

    let(:recruitment_cycle) { build(:recruitment_cycle) }
    let(:provider) { build(:provider, recruitment_cycle: recruitment_cycle) }
    let(:course) do
      build(
        :course,
        provider: provider,
        degree_grade: degree_grade,
        degree_subject_requirements: "Maths A level.",
      )
    end

    before do
      render_inline(described_class.new(course: course.decorate))
    end

    context "when the degree section is incomplete" do
      let(:degree_grade) { nil }

      it "renders a link to the degree section" do
        expect(page).to have_link(
          "Enter degree requirements",
          href: degrees_start_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            provider.recruitment_cycle.year,
            course.course_code,
          ),
        )
      end
    end

    context "when the degree section is complete" do
      context "when degree type is 'two_one'" do
        let(:degree_grade) { "two_one" }

        it "renders '2:1 or above, or equivalent'" do
          expect(page).to have_content("2:1 or above, or equivalent")
        end
      end

      context "when degree type is 'two_two'" do
        let(:degree_grade) { "two_two" }

        it "renders '2:2 or above, or equivalent'" do
          expect(page).to have_content("2:2 or above, or equivalent")
        end
      end

      context "when degree type is 'third_class'" do
        let(:degree_grade) { "third_class" }

        it "renders 'Third class degree or above, or equivalent'" do
          expect(page).to have_content("Third class degree or above, or equivalent")
        end
      end

      context "when degree type is 'not_required'" do
        let(:degree_grade) { "not_required" }

        it "renders 'Third class degree or above, or equivalent'" do
          expect(page).to have_content("An undergraduate degree, or equivalent")
        end
      end

      context "when degree_subject_requirements and a degree grade are present" do
        let(:degree_grade) { "two_one" }

        it "renders the correct content for both attributes" do
          expect(page).to have_content("2:1 or above, or equivalent")
          expect(page).to have_content("Maths A level.")
        end
      end
    end
  end
end
