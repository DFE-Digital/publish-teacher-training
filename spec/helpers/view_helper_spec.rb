# frozen_string_literal: true

require 'rails_helper'

describe ViewHelper do
  include PreviewHelper
  include Rails.application.routes.url_helpers

  describe '#enrichment_error_url' do
    let(:provider) { build(:provider, recruitment_cycle: build(:recruitment_cycle)) }
    let(:course) { build(:course, provider:) }

    it 'returns enrichment error URL' do
      expect(enrichment_error_url(provider_code: 'A1', course:, field: 'about_course')).to eq("/publish/organisations/A1/#{course.recruitment_cycle_year}/courses/#{course.course_code}/about-this-course?display_errors=true#publish-course-information-form-about-course-field-error")
    end

    it 'returns enrichment error URL for base error' do
      expect(enrichment_error_url(provider_code: 'A1', course:, field: 'base', message: 'Select if student visas can be sponsored')).to eq("/publish/organisations/A1/#{Settings.current_recruitment_cycle_year}/student-visa")
    end

    it 'returns the course applications open date url for the error' do
      expect(enrichment_error_url(provider_code: provider.provider_code, course:, field: 'applications_open_from')).to eq("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/applications-open")
    end
  end

  describe '#provider_enrichment_error_url' do
    let(:provider) { build(:provider) }

    it 'returns provider enrichment error URL' do
      expect(provider_enrichment_error_url(provider:, field: 'email')).to eq("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/contact?display_errors=true#provider_email")
    end
  end

  describe '#x_provider_url' do
    let(:course) { create(:course) }

    context 'when preview? is true' do
      def preview?(_) = true

      it 'returns the publish provider url' do
        expect(x_provider_url).to eq(
          provider_publish_provider_recruitment_cycle_course_path(
            course.provider_code,
            course.recruitment_cycle_year,
            course.course_code
          )
        )
      end
    end

    context 'when preview? is false' do
      def preview?(_) = false

      it 'returns the find provider url' do
        expect(x_provider_url).to eq(
          find_provider_path(course.provider_code, course.course_code)
        )
      end
    end
  end

  describe '#x_accrediting_provider_url
' do
    let(:course) { create(:course) }

    context 'when preview? is true' do
      def preview?(_) = true

      it 'returns the publish accrediting provider url' do
        expect(x_accrediting_provider_url).to eq(
          accredited_by_publish_provider_recruitment_cycle_course_path(
            course.provider_code,
            course.recruitment_cycle_year,
            course.course_code
          )
        )
      end
    end

    context 'when preview? is false' do
      def preview?(_) = false

      it 'returns the find accrediting provider url' do
        expect(x_accrediting_provider_url).to eq(
          find_accrediting_provider_path(course.provider_code, course.course_code)
        )
      end
    end
  end
end
