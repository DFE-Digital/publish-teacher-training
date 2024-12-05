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
    context 'with schools' do
      it 'copies the courses with schools' do
        login_user(user)
        post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { 'course[autocompleted_provider_code]' => source_provider.provider_code, schools: '1' }
        expect(target_provider.reload.courses.length).to eq(3)
        courses = target_provider.reload.courses
        expect(courses.flat_map(&:sites).length).to eq(3)
      end
    end

    context 'without schools' do
      it 'copies the course without schools' do
        login_user(user)
        post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { 'course[autocompleted_provider_code]' => source_provider.provider_code }
        expect(target_provider.reload.courses.length).to eq(3)
      end
    end
  end
end
