# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::LengthController, type: :controller do
  render_views
  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }
  let(:course) { create(:course, :published, provider:) }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    controller.instance_variable_set(:@current_user, user)
  end

  describe "#update" do
    let(:params) do
      {
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        code: course.course_code,
        publish_course_length_form: {
          course_length: "TwoYears",
        },
      }
    end

    context "when the course is published and confirmation is required" do
      it "renders the interstitial and does not persist the change" do
        patch :update, params: params

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Your changes will go live immediately.")
        expect(response.body).to include("Continue and publish changes")
        expect(course.reload.enrichments.find_or_initialize_draft.course_length).not_to eq("TwoYears")
      end
    end

    context "when the course is published and confirmation is given" do
      it "persists the change and sets the live success flash" do
        patch :update, params: params.merge(confirm_publish: "true")

        expect(response).to redirect_to(
          publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            provider.recruitment_cycle_year,
            course.course_code,
          ),
        )
        expect(course.reload.enrichments.find_or_initialize_draft.course_length).to eq("TwoYears")
        expect(flash[:success_with_body]).to include(
          "body" => "These changes are now live.",
        )
      end
    end

    context "when the course is a draft" do
      let(:course) { create(:course, :draft_enrichment, provider:) }

      it "saves immediately without rendering the interstitial" do
        patch :update, params: params

        expect(response).to redirect_to(
          publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            provider.recruitment_cycle_year,
            course.course_code,
          ),
        )
        expect(response.body).not_to include("Your changes will go live immediately.")
        expect(course.reload.enrichments.find_or_initialize_draft.course_length).to eq("TwoYears")
      end
    end
  end
end
