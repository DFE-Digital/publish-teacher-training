# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Testing Errors render", service: :publish, type: :request do
  describe "GET /publish/organisations/:provider_code/courses/:course_code.json" do
    include DfESignInUserHelper

    let(:provider) { create(:provider) }
    let(:course) { create(:course, :secondary, provider:) }
    let(:recruitment_cycle_year) { provider.recruitment_cycle.year }

    before do
      user = create(:user, providers: [provider])
      login_user(user)
    end

    describe "not_acceptable - GET /publish/organisations/.../J522.json" do
      it "renders not acceptable html" do
        get "/publish/organisations/#{provider.provider_code}/#{recruitment_cycle_year}/courses/#{course.course_code}.json"

        expect(response).to have_http_status(:not_acceptable)
        expect(response.body).to include("The format requested is not available")
      end
    end

    describe "not_found - GET /publish/organisations/.../wertyu.json" do
      it "returns html response when json format is not found" do
        get "/publish/organisations/#{provider.provider_code}/#{recruitment_cycle_year}/courses/wertyu.json"

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body.text.squish).to include("Page not found If you typed a web address, check it is correct. If you pasted the web address, check you copied the entire address.")
      end
    end

    describe "internal_server_error" do
      it "returns html response when json format is not found" do
        allow(Rails.env).to receive(:test?).and_return(false) # allow error to render template
        # Only way I can find to reliably trigger error in controller context
        allow(RecruitmentCycle).to receive(:find_by!).and_raise(StandardError)
        allow(Sentry).to receive(:capture_exception)

        get "/publish/organisations/#{provider.provider_code}/#{recruitment_cycle_year}/courses/#{course.course_code}"

        expect(Sentry).to have_received(:capture_exception).with(StandardError)
        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body.text.squish).to include("Sorry, there’s a problem with the service Try again later.")
      end
    end
  end
end
