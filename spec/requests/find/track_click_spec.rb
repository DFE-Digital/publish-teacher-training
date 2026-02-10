# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /track_click", service: :find do
  context "when a candidate is signed in" do
    before do
      FeatureFlag.activate(:candidate_accounts)
      CandidateAuthHelper.mock_auth
      @candidate = create(:find_developer_candidate)

      post "/auth/find-developer"
      follow_redirect!
    end

    it "includes the signed-in user in the click event" do
      captured_user = nil
      allow(Find::Analytics::ClickEvent).to receive(:new).and_wrap_original do |method, **args|
        event = method.call(**args)
        allow(event).to receive(:send_event) { captured_user = event.current_user }
        event
      end

      get "/track_click", params: { url: "/secondary", utm_content: "test" }

      expect(captured_user).to eq(@candidate)
    end
  end

  context "when no candidate is signed in" do
    it "does not have a current user for the click event" do
      captured_user = :not_called
      allow(Find::Analytics::ClickEvent).to receive(:new).and_wrap_original do |method, **args|
        event = method.call(**args)
        allow(event).to receive(:send_event) { captured_user = event.current_user }
        event
      end

      get "/track_click", params: { url: "/secondary", utm_content: "test" }

      expect(captured_user).to be_nil
    end
  end
end
