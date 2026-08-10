# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::LengthController, type: :controller do
  render_views
  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }
  # The course starts on a length that is pinned, and deliberately not the one
  # these examples submit. Left to the factory it is picked at random from a
  # list that includes "TwoYears", and on the runs where it came up the course
  # already had the length being submitted - so "did not persist the change"
  # could not be told apart from "did".
  let(:original_course_length) { "OneYear" }
  let(:new_course_length) { "TwoYears" }
  let(:course) do
    create(
      :course,
      :published,
      provider:,
      enrichments: [build(:course_enrichment, :published, course_length: original_course_length)],
    )
  end

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
          course_length: new_course_length,
        },
      }
    end

    context "when the course is published and confirmation is required" do
      it "renders the interstitial and does not persist the change" do
        patch :update, params: params

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Your changes will go live immediately.")
        expect(response.body).to include("Continue and publish changes")
        expect(course.reload.enrichments.find_or_initialize_draft.course_length).to eq(original_course_length)
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
        expect(course.reload.enrichments.find_or_initialize_draft.course_length).to eq(new_course_length)
        expect(flash[:success_with_body]).to include(
          "body" => "These changes are now live.",
        )
      end
    end

    context "when the course is a draft" do
      # Pinned for the same reason: otherwise the draft can start on the length
      # being submitted, and the example passes without saving anything.
      let(:course) do
        create(
          :course,
          provider:,
          enrichments: [build(:course_enrichment, :initial_draft, course: nil, course_length: original_course_length)],
        )
      end

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
        expect(course.reload.enrichments.find_or_initialize_draft.course_length).to eq(new_course_length)
      end
    end
  end
end
