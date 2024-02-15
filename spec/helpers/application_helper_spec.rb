# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  include ViewHelper
  include GovukVisuallyHiddenHelper
  include GovukComponentsHelper
  include GovukLinkHelper

  describe '#enrichment_error_link' do
    context 'with a course' do
      before do
        @provider = build(:provider)
        @course = build(:course, provider: @provider)
      end

      it 'returns correct content' do
        expect(enrichment_error_link(:course, 'about_course', 'Something about the course'))
          .to eq("<div class=\"govuk-inset-text app-inset-text--narrow-border app-inset-text--error\"><a class=\"govuk-link\" href=\"/publish/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/about?display_errors=true#publish-course-information-form-about-course-field-error\">Something about the course</a></div>")
      end
    end
  end

  describe '#enrichment_summary' do
    subject { render(summary_list) }

    let(:summary_list) { GovukComponent::SummaryListComponent.new }

    context 'with a value' do
      before do
        enrichment_summary(summary_list, :course, 'About course', 'Something about the course', %w[about])
      end

      it 'injects the provided content into the provided summary list row' do
        expect(subject).to have_css(%(.govuk-summary-list__row[data-qa="enrichment__about"]))
        expect(subject).to have_css('.govuk-summary-list__key', text: 'About course')
        expect(subject).to have_css('.govuk-summary-list__value.app-summary-list__value--truncate', text: 'Something about the course')
      end
    end

    context 'with errors' do
      let(:error_message) { 'Enter something about the course' }

      before do
        @provider = build_stubbed(:provider)
        @course = build_stubbed(:course, provider: @provider)
        @errors = { about_course: [error_message] }

        enrichment_summary(summary_list, :course, 'About course', '', [:about_course])
      end

      it 'renders a value containing an error link within inset text' do
        expect(subject).to have_css('.govuk-summary-list__key', text: 'About course')
        expect(subject).to have_css('.govuk-summary-list__value > .app-inset-text--error > a', text: error_message)

        expect(subject).to have_link(error_message, href: "/publish/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/about?display_errors=true#publish-course-information-form-about-course-field-error")
      end
    end
  end
end
