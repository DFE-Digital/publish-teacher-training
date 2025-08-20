# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CoursesController do
    let(:user) { create(:user, :with_provider) }
    let(:provider) { user.providers.first }

    let(:course) do
      create(
        :course,
        :with_gcse_equivalency,
        :with_accrediting_provider,
        enrichments: [build(:course_enrichment, :initial_draft)],
        sites: [create(:site, location_name: "location 1")],
        study_sites: [create(:site, :study_site)],
        provider:,
      )
    end

    before do
      allow(controller).to receive(:authenticate).and_return(true)
      controller.instance_variable_set(:@current_user, user)
    end

    describe "#Publish" do
      it "calls NotificationService::CoursePublished when successful" do
        expect(NotificationService::CoursePublished).to receive(:call).with(course:)

        post :publish, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: course.course_code,
        }
      end

      describe "When rolled over v1 enrichment exists" do
        let(:v1_enrichment) { create(:course_enrichment, :v1, status: "rolled_over", course:) }
        let(:v2_enrichment) { create(:course_enrichment, :v2, status: "draft", course:) }

        before do
          allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(false)
          v1_enrichment
          allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)
          v2_enrichment
        end

        it "updates the v2 enrichment to published" do
          post :publish, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            code: course.course_code,
          }

          expect(v2_enrichment.reload.status).to eq "published"
        end
      end
    end

    describe "#apply" do
      it "redirects" do
        get :apply, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: course.course_code,
        }

        expect(response).to redirect_to("https://www.apply-for-teacher-training.service.gov.uk/candidate/apply?providerCode=#{provider.provider_code}&courseCode=#{course.course_code}")
      end
    end
  end
end
