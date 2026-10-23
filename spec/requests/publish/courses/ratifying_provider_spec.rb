# frozen_string_literal: true

require "rails_helper"

describe "Publish::Courses::RatifyingProviderController#update", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }
  let(:course) { create(:course, provider:) }

  before { login_user(user) }

  it "shows a validation error when no accredited provider is submitted" do
    put ratifying_provider_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      provider.recruitment_cycle_year,
      course.course_code,
    )

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Select an accredited provider")
    expect(course.reload.accredited_provider_code).to be_nil
  end
end
