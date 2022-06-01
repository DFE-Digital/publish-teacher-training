require "rails_helper"

module Publish
  describe CoursesController do
    let(:user) { create(:user, :with_provider) }
    let(:provider) { user.providers.first }

    let(:course) do
      create(
        :course,
        :with_gcse_equivalency,
        enrichments: [build(:course_enrichment, :initial_draft)],
        sites: [create(:site, location_name: "location 1")],
        provider: provider,
      )
    end

    describe "#Publish" do
      before do
        allow(controller).to receive(:authenticate).and_return(true)
        controller.instance_variable_set(:@current_user, user)
        given_the_can_edit_current_and_next_cycles_feature_flag_is_disabled
      end

      it "calls NotificationService::CoursePublished when successful" do
        expect(NotificationService::CoursePublished).to receive(:call).with(course: course)

        post :publish, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: course.course_code,
        }
      end
    end
  end
end
