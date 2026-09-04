# frozen_string_literal: true

require "rails_helper"

describe "Publish::Courses::Schools::BulkUpdatesController" do
  include DfESignInUserHelper

  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }
  let(:course) { create(:course, :secondary, :with_schools, provider:) }
  let(:draft) do
    Publish::Schools::BulkUpdate::Draft.create(
      course:,
      school_uuids: %w[a b],
      baseline_uuids: %w[b],
    )
  end

  def bulk_update_path(state_key)
    "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}" \
      "/courses/#{course.course_code}/schools/bulk-update/#{state_key}"
  end

  def get_options(state_key)
    login_user(user)
    get bulk_update_path(state_key)
  end

  it "asks what courses the change applies to" do
    get_options(draft.state_key)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("What courses do you want to apply this change to?")
  end

  it "sends an unknown selection back to the placement schools page" do
    get_options(SecureRandom.uuid)

    expect(response).to redirect_to(
      "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}" \
        "/courses/#{course.course_code}/schools",
    )
    expect(flash[:warning]).to eq("Your school selection has expired. Select the schools you want again.")
  end

  it "sends an expired selection back to the placement schools page" do
    state_key = draft.state_key

    travel(Publish::Schools::BulkUpdate::Draft::EXPIRES_IN + 1.minute) do
      get_options(state_key)

      expect(response).to redirect_to(
        "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}" \
          "/courses/#{course.course_code}/schools",
      )
    end
  end

  it "does not resolve a selection made against another course" do
    other = create(:course, :secondary, :with_schools, provider:)
    other_draft = Publish::Schools::BulkUpdate::Draft.create(
      course: other,
      school_uuids: %w[a],
      baseline_uuids: [],
    )

    get_options(other_draft.state_key)

    expect(response).to have_http_status(:redirect)
  end

  it "does not let a user reach another provider's course" do
    stranger = create(:course, :secondary, :with_schools)
    stranger_draft = Publish::Schools::BulkUpdate::Draft.create(
      course: stranger,
      school_uuids: %w[a],
      baseline_uuids: [],
    )

    login_user(user)
    get "/publish/organisations/#{stranger.provider_code}/#{stranger.recruitment_cycle_year}" \
          "/courses/#{stranger.course_code}/schools/bulk-update/#{stranger_draft.state_key}"

    expect(response).not_to have_http_status(:ok)
  end
end
