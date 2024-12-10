# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Support::CopyCourses' do
  include DfESignInUserHelper
  let(:user) { create(:user, :admin) }
  let(:source_provider) { create(:provider, courses: create_list(:course, 3, :with_full_time_sites)) }
  let!(:target_provider) { create(:provider, sites: source_provider.courses.flat_map(&:sites)) }
  let!(:year) { find_or_create(:recruitment_cycle).year }

  before { host! URI(Settings.base_url).host }

  describe 'GET new' do
    it 'responds with 200' do
      login_user(user)
      get "/support/2025/providers/#{source_provider.id}/copy_courses/new"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST create' do
    it 'copies the courses and shows flash message' do
      login_user(user)
      post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { 'course[autocompleted_provider_code]' => source_provider.provider_code }
      expect(target_provider.reload.courses.length).to eq(3)

      expect(response).to redirect_to(support_recruitment_cycle_provider_courses_path(year, target_provider.id))
      follow_redirect!
      expect(response.parsed_body.css('.govuk-notification-banner--success').text).to match(format('Courses copied: %s', source_provider.courses.map(&:course_code).to_sentence))
    end

    context 'with schools' do
      it 'copies the courses with schools' do
        login_user(user)
        post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { 'course[autocompleted_provider_code]' => source_provider.provider_code, schools: '1' }
        expect(target_provider.reload.courses.length).to eq(3)
        courses = target_provider.reload.courses
        expect(courses.flat_map(&:sites).length).to eq(3)
        expect(response).to redirect_to(support_recruitment_cycle_provider_courses_path(year, target_provider.id))
        follow_redirect!
        expect(response.parsed_body.css('.govuk-notification-banner--success').text).to match(format('Courses copied: %s', source_provider.courses.map(&:course_code).to_sentence))
      end
    end

    context 'course code already exists on target provider' do
      let(:source_provider) { create(:provider, courses: [create(:course)]) }
      let!(:target_provider) { create(:provider, courses: [create(:course, course_code: source_provider.courses.first.course_code)]) }

      it 'notifies user that the course was not copied' do
        login_user(user)
        post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { 'course[autocompleted_provider_code]' => source_provider.provider_code }

        expect(response).to redirect_to(support_recruitment_cycle_provider_courses_path(year, target_provider.id))
        follow_redirect!

        expect(response.parsed_body.css('.govuk-notification-banner--warning').text).to match(format('Courses not copied: %s', source_provider.courses.map(&:course_code).to_sentence))
      end
    end

    context 'when copying courses to the same provider' do
      it 'renders the new action with error messages' do
        login_user(user)
        post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { 'course[autocompleted_provider_code]' => target_provider.provider_code }
        expect(response).to render_template(:new)
        expect(response.parsed_body.css('.govuk-error-summary').text).to match('Choose different providers')
      end
    end
  end
end
