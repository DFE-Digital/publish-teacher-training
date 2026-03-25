# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /candidate/saved-courses/after_auth", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
  end

  it "does not save anything and redirects safely when session key is missing" do
    expect(Find::SaveCourseService).not_to receive(:call)
    expect { get "/candidate/saved-courses/after_auth" }.not_to change(SavedCourse, :count)

    expect(response).to have_http_status(:redirect)
    expect(response).to redirect_to(find_root_path)
  end

  it "saves the course and redirects back to the course page when session key is present" do
    CandidateAuthHelper.mock_auth
    create(:find_developer_candidate)

    course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :with_special_education_needs,
      :published,
      :open,
      provider: build(:provider, provider_name: "York university", provider_code: "RO1"),
    )

    # Visit the sign-in page (unauthenticated), then initiate the OmniAuth request phase with course_id.
    get "/candidate/saved-courses/sign_in", params: { course_id: course.id }
    post "/auth/find-developer", params: { course_id: course.id }

    follow_redirect! # to callback
    follow_redirect! # to after_auth (since save intent is in session)
    follow_redirect! # to course page

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Course saved")
    expect(SavedCourse.count).to eq(1)
  end

  it "redirects back to results when saving from the results page" do
    CandidateAuthHelper.mock_auth
    create(:find_developer_candidate)

    course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :with_special_education_needs,
      :published,
      :open,
      provider: build(:provider, provider_name: "York university", provider_code: "RO1"),
    )

    # Simulate visiting the results page (sets the results_path cookie)
    cookies[:results_path] = find_results_path

    # Visit sign_in with a results page referer so the session flag is set
    get "/candidate/saved-courses/sign_in",
        params: { course_id: course.id },
        headers: { "HTTP_REFERER" => "http://#{Settings.find_hosts.first}#{find_results_path}" }

    post "/auth/find-developer", params: { course_id: course.id }

    follow_redirect! # to callback
    follow_redirect! # to after_auth

    expect(response).to redirect_to(find_results_path)

    follow_redirect! # to results page

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Course saved")
    expect(SavedCourse.count).to eq(1)
  end

  it "ignores a tampered results_path cookie and redirects to the course page" do
    CandidateAuthHelper.mock_auth
    create(:find_developer_candidate)

    course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :with_special_education_needs,
      :published,
      :open,
      provider: build(:provider, provider_name: "York university", provider_code: "RO1"),
    )

    # Tampered cookie with a non-results path
    cookies[:results_path] = "/malicious_url"

    get "/candidate/saved-courses/sign_in",
        params: { course_id: course.id },
        headers: { "HTTP_REFERER" => "http://#{Settings.find_hosts.first}/results" }

    post "/auth/find-developer", params: { course_id: course.id }

    follow_redirect! # to callback
    follow_redirect! # to after_auth
    follow_redirect! # to course page

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Course saved")
    expect(SavedCourse.count).to eq(1)
  end
end
