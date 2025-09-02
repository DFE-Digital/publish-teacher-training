# frozen_string_literal: true

require "rails_helper"

module CoursePreview
  describe MissingInformationComponent, type: :component do
    include Rails.application.routes.url_helpers

    let(:provider) { create(:provider, provider_code: "Y25") }
    let(:accrediting_provider) { build(:provider) }
    let(:course) { Course.new(provider:, course_code:, accrediting_provider:) }
    let(:provider_code) { provider.provider_code }
    let(:recruitment_cycle_year) { provider.recruitment_cycle_year }
    let(:course_code) { "4GET" }

    def hrefs_for_cycle(year)
      year = year.to_i
      base = {
        about_this_course: about_this_course_publish_provider_recruitment_cycle_course_path(
          provider_code, recruitment_cycle_year, course_code, goto_preview: true
        ),
        degree: degrees_start_publish_provider_recruitment_cycle_course_path(
          provider_code, recruitment_cycle_year, course_code, goto_preview: true
        ),
        fee_uk_eu: fees_publish_provider_recruitment_cycle_course_path(
          provider_code, recruitment_cycle_year, course_code, goto_preview: true
        ),
        gcse: gcses_pending_or_equivalency_tests_publish_provider_recruitment_cycle_course_path(
          provider_code, recruitment_cycle_year, course_code, goto_preview: true
        ),
        how_school_placements_work: school_placements_publish_provider_recruitment_cycle_course_path(
          provider_code, recruitment_cycle_year, course_code, goto_preview: true
        ),
      }

      if year < 2025
        base.merge(
          train_with_us: about_publish_provider_recruitment_cycle_path(
            provider_code, recruitment_cycle_year, course_code:, goto_provider: true, anchor: "train-with-us"
          ),
          train_with_disability: about_publish_provider_recruitment_cycle_path(
            provider_code, recruitment_cycle_year, course_code:, goto_training_with_disabilities: true, anchor: "train-with-disability"
          ),
        )
      else
        base.merge(
          train_with_us: edit_publish_provider_recruitment_cycle_why_train_with_us_path(
            provider_code, recruitment_cycle_year, course_code:, goto_provider: true
          ),
          train_with_disability: edit_publish_provider_recruitment_cycle_disability_support_path(
            provider_code, recruitment_cycle_year, course_code:, goto_training_with_disabilities: true
          ),
        )
      end
    end

    shared_examples "course with missing information" do |information_type, text|
      it "renders link for missing #{information_type}" do
        render_inline(described_class.new(course:, information_type:, is_preview: true))
        expect(page).to have_link(text, href: hrefs[information_type])
      end
    end

    context "when recruitment cycle is before 2025" do
      before do
        Current.recruitment_cycle = create(:recruitment_cycle, year: 2024)
        allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(false)
      end

      let(:hrefs) { hrefs_for_cycle(Current.recruitment_cycle.year) }

      include_examples "course with missing information", :about_this_course, "Enter course details"
      include_examples "course with missing information", :degree, "Enter degree requirements"
      include_examples "course with missing information", :fee_uk_eu, "Enter details about fees and financial support"
      include_examples "course with missing information", :gcse, "Enter GCSE and equivalency test requirements"
      include_examples "course with missing information", :how_school_placements_work, "Enter details about how placements work"
      include_examples "course with missing information", :train_with_us, "Enter details about the training provider"
      include_examples "course with missing information", :train_with_disability, "Enter details about training with disabilities and other needs"
    end

    context "when recruitment cycle is 2025 or later" do
      before do
        rc = create(:recruitment_cycle, year: 2025)
        allow(rc).to receive(:after_2025?).and_return(true)
        Current.recruitment_cycle = rc
        allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(false)
      end

      let(:hrefs) { hrefs_for_cycle(Current.recruitment_cycle.year) }

      include_examples "course with missing information", :about_this_course, "Enter course details"
      include_examples "course with missing information", :degree, "Enter degree requirements"
      include_examples "course with missing information", :fee_uk_eu, "Enter details about fees and financial support"
      include_examples "course with missing information", :gcse, "Enter GCSE and equivalency test requirements"
      include_examples "course with missing information", :how_school_placements_work, "Enter details about how placements work"
      include_examples "course with missing information", :train_with_us, "Enter details about the training provider"
      include_examples "course with missing information", :train_with_disability, "Enter details about training with disabilities and other needs"
    end
  end
end
