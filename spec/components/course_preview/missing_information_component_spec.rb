# frozen_string_literal: true

require 'rails_helper'

module CoursePreview
  describe MissingInformationComponent, type: :component do
    include Rails.application.routes.url_helpers

    context 'when the course is incomplete' do
      let(:provider) { build(:provider) }
      let(:course) { Course.new(provider:, course_code:) }
      let(:provider_code) { provider.provider_code }
      let(:recruitment_cycle_year) { provider.recruitment_cycle_year }
      let(:course_code) { '4GET' }

      let(:hrefs) do
        { about_course:
        about_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
          degree:
        degrees_start_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
          fee_uk_eu:
        fees_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
          gcse:
        gcses_pending_or_equivalency_tests_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
          how_school_placements_work:
        "#{about_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)}#how-school-placements-work" }
      end

      shared_examples 'course with missing information' do |information_type, text|
        before do
          allow(Settings.features).to receive(:course_preview_missing_information).and_return(true)
        end

        it "renders link for missing #{information_type}" do
          render_inline(described_class.new(course:, information_type:))

          href = hrefs[information_type]
          expect(page).to have_link(text, href:)
        end
      end

      include_examples 'course with missing information', :about_course, 'Enter course summary'
      include_examples 'course with missing information', :degree, 'Enter degree requirements'
      include_examples 'course with missing information', :fee_uk_eu, 'Enter details about fees and financial support'
      include_examples 'course with missing information', :gcse, 'Enter GCSE and equivalency test requirements'
      include_examples 'course with missing information', :how_school_placements_work, 'Enter details about school placements'
    end
  end
end
