# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Testing Errors render", type: :request do
  describe "GET /publish/organisations/:provider_code/courses/:course_code.json" do
    include DfESignInUserHelper
    let(:provider) { create(:provider) }
    let(:course) { create(:course, :secondary, provider:) }
    let(:recruitment_cycle_year) { provider.recruitment_cycle.year }

    before do
      host! URI(Settings.publish_url).host
      user = create(:user, providers: [provider])
      login_user(user)
    end

    it "returns html response when json format is not found" do
      get "/publish/organisations/#{provider.provider_code}/#{recruitment_cycle_year}/courses/#{course.course_code}.json"

      expect(response).to have_http_status(:not_acceptable)
      expect(response.body).to include("The format requested is not available")
    end
  end
end
