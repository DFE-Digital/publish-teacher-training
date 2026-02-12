# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TrackController", service: :find, type: :request do
  describe "GET /track_click" do
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

  describe "GET /track_apply_to_course_click" do
    let(:course) { create(:course) }

    it "sends both a click event and a candidate applies event" do
      click_event = instance_double(Find::Analytics::ClickEvent, send_event: nil)
      applies_event = instance_double(Find::Analytics::CandidateAppliesEvent, send_event: nil)

      allow(Find::Analytics::ClickEvent).to receive(:new).and_return(click_event)
      allow(Find::Analytics::CandidateAppliesEvent).to receive(:new).and_return(applies_event)

      get "/track_apply_to_course_click", params: { url: "/apply", utm_content: "confirm_apply_course_button", course_id: course.id }

      expect(click_event).to have_received(:send_event)
      expect(applies_event).to have_received(:send_event)
    end

    it "redirects to the given url" do
      allow(Find::Analytics::ClickEvent).to receive(:new).and_return(instance_double(Find::Analytics::ClickEvent, send_event: nil))
      allow(Find::Analytics::CandidateAppliesEvent).to receive(:new).and_return(instance_double(Find::Analytics::CandidateAppliesEvent, send_event: nil))

      get "/track_apply_to_course_click", params: { url: "/apply", utm_content: "confirm_apply_course_button", course_id: course.id }

      expect(response).to redirect_to("/apply")
    end

    it "passes the course_id to the candidate applies event" do
      allow(Find::Analytics::ClickEvent).to receive(:new).and_return(instance_double(Find::Analytics::ClickEvent, send_event: nil))
      allow(Find::Analytics::CandidateAppliesEvent).to receive(:new).and_return(instance_double(Find::Analytics::CandidateAppliesEvent, send_event: nil))

      get "/track_apply_to_course_click", params: { url: "/apply", utm_content: "confirm_apply_course_button", course_id: course.id }

      expect(Find::Analytics::CandidateAppliesEvent).to have_received(:new).with(
        request: anything,
        course_id: course.id.to_s,
      )
    end
  end
end
