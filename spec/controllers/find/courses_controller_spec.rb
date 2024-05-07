# frozen_string_literal: true

require 'rails_helper'

module Find
  describe CoursesController do
    before do
      Timecop.travel(Find::CycleTimetable.mid_cycle)
    end

    let(:user) { create(:user, :with_provider) }
    let(:provider) { user.providers.first }

    let(:course) do
      create(
        :course,
        :with_gcse_equivalency,
        enrichments: [build(:course_enrichment, :initial_draft)],
        sites: [create(:site, location_name: 'location 1')],
        provider:
      )
    end

    describe '#apply' do
      it 'redirects' do
        expect(Rails.logger).to receive(:info).with("Course apply conversion. Provider: #{course.provider.provider_code}. Course: #{course.course_code}").once
        expect(Rails.logger).to receive(:info)

        get :apply, params: {
          provider_code: provider.provider_code,
          course_code: course.course_code
        }

        expect(response).to redirect_to("https://www.apply-for-teacher-training.service.gov.uk/candidate/apply?providerCode=#{provider.provider_code}&courseCode=#{course.course_code}")
      end

      it 'redirects when downcase provider and course code' do
        get :apply, params: {
          provider_code: provider.provider_code.downcase,
          course_code: course.course_code.downcase
        }

        expect(response).to redirect_to("https://www.apply-for-teacher-training.service.gov.uk/candidate/apply?providerCode=#{provider.provider_code}&courseCode=#{course.course_code}")
      end

      it 'raises a not found error when the provider does not exist' do
        get :apply, params: {
          provider_code: 'ABCD',
          course_code: course.course_code.downcase
        }

        expect(response).to be_not_found
      end

      it 'when course does not exist' do
        get :apply, params: {
          provider_code: provider.provider_code,
          course_code: 'ABCD'
        }

        expect(response).to be_not_found
      end
    end

    describe '#show' do
      it 'renders the not found page' do
        get :show, params: {
          provider_code: 'ABC',
          course_code: '123'
        }

        expect(response).to render_template('errors/not_found')
      end
    end
  end
end
