# frozen_string_literal: true

require "rails_helper"

describe "GET /publish/organisations/:provider_code/:year/courses/new" do
  let(:provider) { create(:provider) }

  it "redirects to the add course wizard with a fresh state key" do
    get "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/new"

    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(
      %r{\A(http://[^/]+)?/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/course_wizard/new\?state_key=\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z},
    )
  end
end
