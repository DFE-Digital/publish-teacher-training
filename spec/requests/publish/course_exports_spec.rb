# frozen_string_literal: true

require "rails_helper"

describe "Publish::Courses::ExportsController" do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:user) { create(:user, providers: [provider]) }

  def download(path)
    get "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/courses/#{path}.csv"
  end

  {
    "download-course-information" => "course-information",
    "download-course-schools" => "schools-attached-to-courses",
  }.each do |path, filename|
    describe "/#{path}" do
      context "when the user is attached to the provider" do
        before do
          create(:course, provider:)
          login_user(user)
          download(path)
        end

        it "sends a CSV" do
          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq("text/csv")
        end

        it "sends it as a dated attachment" do
          expect(response.headers["Content-Disposition"])
            .to include("attachment", "#{filename}-#{provider.provider_code}-#{Time.zone.today}.csv")
        end
      end

      context "when the user is not attached to the provider" do
        it "is forbidden" do
          login_user(create(:user, providers: [create(:provider)]))
          download(path)

          expect(response).to have_http_status(:forbidden)
        end
      end

      context "when the user is not authenticated" do
        it "is redirected to sign in" do
          download(path)

          expect(response).to redirect_to("/sign-in")
        end
      end
    end
  end
end
