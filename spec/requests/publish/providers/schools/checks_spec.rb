# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish provider school checks", type: :request do
  include DfESignInUserHelper

  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }

  before { login_user(user) }

  it "adds an available GIAS school" do
    available_school = create(:gias_school, :open)

    expect {
      put publish_provider_recruitment_cycle_schools_check_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        school_id: available_school.id,
      )
    }.to change { provider.schools.count }.by(1)
  end

  it "does not add an unavailable GIAS school" do
    closed_school = create(:gias_school, :closed)

    expect {
      put publish_provider_recruitment_cycle_schools_check_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        school_id: closed_school.id,
      )
    }.not_to(change { provider.schools.count })

    expect(response).to have_http_status(:not_found)
  end
end
