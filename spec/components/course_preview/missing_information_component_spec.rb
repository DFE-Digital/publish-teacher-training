# frozen_string_literal: true

require "rails_helper"

module CoursePreview
  describe MissingInformationComponent, type: :component do
    include Rails.application.routes.url_helpers

    context "when the course is incomplete" do
      let(:provider) { build(:provider) }
      let(:accrediting_provider) { build(:provider) }
      let(:course) { Course.new(provider:, course_code:, accrediting_provider:) }
      let(:provider_code) { provider.provider_code }
      let(:recruitment_cycle_year) { provider.recruitment_cycle_year }
      let(:course_code) { "4GET" }

      let(:hrefs) do
        {
          about_this_course:
        about_this_course_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
          degree:
        degrees_start_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
          fee_uk_eu:
        fees_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
          gcse:
        gcses_pending_or_equivalency_tests_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
          how_school_placements_work:
        school_placements_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
          train_with_disability:
        "#{about_publish_provider_recruitment_cycle_path(provider_code, recruitment_cycle_year, course_code:, goto_training_with_disabilities: true)}#train-with-disability",
          train_with_us:
        "#{about_publish_provider_recruitment_cycle_path(provider_code, recruitment_cycle_year, course_code:, goto_provider: true)}#train-with-us",
        }
      end

      shared_examples "course with missing information" do |information_type, text|
        it "renders link for missing #{information_type}" do
          render_inline(described_class.new(course:, information_type:, is_preview: true))

          expect(page).to have_link(text, href: hrefs[information_type])
        end
      end

      include_examples "course with missing information", :about_this_course, "Enter course details"
      include_examples "course with missing information", :degree, "Enter degree requirements"
      include_examples "course with missing information", :fee_uk_eu, "Enter details about fees and financial support"
      include_examples "course with missing information", :gcse, "Enter GCSE and equivalency test requirements"
      include_examples "course with missing information", :how_school_placements_work, "Enter details about how placements work"
      include_examples "course with missing information", :train_with_disability, "Enter details about training with disabilities and other needs"
      include_examples "course with missing information", :train_with_us, "Enter details about the training provider"
    end
  end
end
