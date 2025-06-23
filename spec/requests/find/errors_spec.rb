# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Testing Errors render", service: :find, type: :request do
  describe "not_acceptable - GET /results.*" do
    before do
      create(:course, :secondary)
    end

    it "returns html response when json format is not found" do
      get "/results.json"

      expect(response).to have_http_status(:not_acceptable)
      expect(response.body).to include("The format requested is not available")
    end
  end

  describe "not_found - GET /courses/not/found" do
    it "returns html response when json format is not found" do
      get "/course/not/found"

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body.text.squish).to include("Page not found If you typed a web address, check it is correct. If you pasted the web address, check you copied the entire address.")
    end
  end

  describe "internal_server_error" do
    it "returns html response when json format is not found" do
      allow(Sentry).to receive(:capture_exception)
      allow(Rails.env).to receive(:test?).and_return(false) # allow error to render template
      allow(RecruitmentCycle).to receive(:current).and_raise(StandardError)

      get "/course/not/found"

      expect(Sentry).to have_received(:capture_exception).with(StandardError)
      expect(response).to have_http_status(:internal_server_error)
      expect(response.parsed_body.text.squish).to include("Sorry, there’s a problem with the service Try again later.")
    end
  end
end
