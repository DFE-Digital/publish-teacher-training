# frozen_string_literal: true

require "rails_helper"

module Find
  describe "/results" do
    before do
      host! "www.find-example.com"
    end

    context "when page parameter is invalid" do
      before do
        get "/results", params: { page: "some-site-.co.uk" }
      end

      it "responds successfully" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
