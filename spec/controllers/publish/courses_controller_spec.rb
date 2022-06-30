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
        provider:,
      )
    end

    describe "#Publish", { can_edit_current_and_next_cycles: false } do
      before do
        allow(controller).to receive(:authenticate).and_return(true)
        controller.instance_variable_set(:@current_user, user)
      end

      it "calls NotificationService::CoursePublished when successful" do
        expect(NotificationService::CoursePublished).to receive(:call).with(course:)

        post :publish, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: course.course_code,
        }
      end
    end
  end
end
