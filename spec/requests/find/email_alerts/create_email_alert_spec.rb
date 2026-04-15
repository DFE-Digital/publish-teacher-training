# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Create Email alert with subjects", service: :find, type: :request do
  before do
    create(:find_developer_candidate)
    FeatureFlag.activate(:email_alerts)
    FeatureFlag.activate(:candidate_accounts)

    CandidateAuthHelper.mock_auth
  end

  describe "POST /auth/find-developer" do
    context "one subject" do
      it "triggers an error and renders the error page" do
        post "/auth/find-developer"
        follow_redirect!
        follow_redirect!

        expect {
          post("/candidate/email-alerts", params: {
            "minimum_degree_required" => "show_all_courses",
            "subject_code" => "G1",
            "subject_name" => "Mathematics",
          })
        }.to change(Candidate::EmailAlert, :count).from(0).to(1)

        expect(Candidate::EmailAlert.last).to have_attributes({ subjects: %w[G1] })

        expect(response).to have_http_status(:redirect)
      end
    end

    context "two subjects" do
      it "triggers an error and renders the error page" do
        post "/auth/find-developer"
        follow_redirect!
        follow_redirect!

        expect {
          post("/candidate/email-alerts", params: {
            "utm_source" => "results",
            "previous_location_category" => "",
            "subject_name" => "French",
            "subject_code" => "15",
            "location" => "",
            "utm_medium" => "search",
            "order" => "course_name_ascending",
            "subjects[]" => "17",
            "minimum_degree_required" => "show_all_courses",
            "provider_code" => "",
          })
        }.to change(Candidate::EmailAlert, :count).from(0).to(1)

        expect(Candidate::EmailAlert.last).to have_attributes({ subjects: %w[15 17] })

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
