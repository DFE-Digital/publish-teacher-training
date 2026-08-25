# frozen_string_literal: true

require "rails_helper"

describe "Publish::Providers::TrainingPartners::CourseExportsController" do
  include DfESignInUserHelper

  let(:accreditor) { create(:accredited_provider) }
  let(:user) { create(:user, providers: [accreditor]) }

  def download
    get "/publish/organisations/#{accreditor.provider_code}/#{accreditor.recruitment_cycle.year}/training-providers-courses.csv"
  end

  describe "/training-providers-courses" do
    context "when the user is attached to the accredited provider" do
      before do
        create(:course, provider: create(:provider), accrediting_provider: accreditor)
        login_user(user)
        download
      end

      it "sends a CSV" do
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/csv")
      end

      it "sends it as a dated attachment" do
        expect(response.headers["Content-Disposition"])
          .to include("attachment", "courses-#{Time.zone.today}.csv")
      end
    end

    context "when the user is not attached to the accredited provider" do
      it "is forbidden" do
        login_user(create(:user, providers: [create(:provider)]))
        download

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when the user is not authenticated" do
      it "is redirected to sign in" do
        download

        expect(response).to redirect_to("/sign-in")
      end
    end
  end
end
