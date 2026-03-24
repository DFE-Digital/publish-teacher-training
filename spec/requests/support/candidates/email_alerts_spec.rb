# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::Candidates::EmailAlerts" do
  include DfESignInUserHelper

  let(:user) { create(:user, :admin) }
  let(:candidate) { create(:candidate) }

  before do
    host! URI(Settings.base_url).host
    login_user(user)
  end

  describe "GET /support/candidates/:candidate_id/email_alerts" do
    it "displays subject names for email alerts with subjects in the subjects column" do
      create_subjects!
      create(:email_alert, candidate:, subjects: %w[C1 F1], location_name: "London")

      get "/support/candidates/#{candidate.id}/email_alerts"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Biology")
      expect(response.body).to include("Chemistry")
    end

    it "displays subject name when subject is only in search_attributes subject_code" do
      create_subjects!
      create(:email_alert, candidate:, subjects: [], search_attributes: { "subject_code" => "C1" }, location_name: "London")

      get "/support/candidates/#{candidate.id}/email_alerts"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Biology")
    end

    it "renders without error when search_attributes is nil" do
      create(:email_alert, candidate:, subjects: [], search_attributes: nil, location_name: "London")

      get "/support/candidates/#{candidate.id}/email_alerts"

      expect(response).to have_http_status(:ok)
    end
  end

private

  def create_subjects!
    subject_area = SubjectArea.find_or_create_by!(typename: "SecondarySubject", name: "Secondary")
    Subject.find_or_create_by!(subject_code: "C1") do |s|
      s.subject_name = "Biology"
      s.type = "SecondarySubject"
      s.subject_area = subject_area
    end
    Subject.find_or_create_by!(subject_code: "F1") do |s|
      s.subject_name = "Chemistry"
      s.type = "SecondarySubject"
      s.subject_area = subject_area
    end
  end
end
