require "rails_helper"

describe API::V2::CoursesController, type: :controller do
  describe "#publish" do
    let(:enrichment) { build(:course_enrichment, :initial_draft) }
    let(:site_status) { build(:site_status, :new) }
    let(:dfe_subject) { find_or_create(:primary_subject, :primary) }
    let(:course) {
      create(:course,
             site_statuses: [site_status],
             enrichments: [enrichment],
             subjects: [dfe_subject])
    }
    let(:publish_course_service) { double }
    let(:email) { "manage_courses@digital.education.gov.uk" }
    let(:sign_in_user_id) { "manage_courses_api" }
    let(:existing_user) do
      create(
        :user, admin: true,
        email: email,
        sign_in_user_id: sign_in_user_id
      )
    end

    before do
      allow(controller).to receive(:authenticate).and_return(true)
      controller.instance_variable_set(:@current_user, existing_user)
    end

    it "executes publish course service" do
      allow(Courses::PublishCourseService).to receive(:new).and_return(publish_course_service)
      expect(publish_course_service).to receive(:execute).with(course: course)
      post :publish, params: {
        recruitment_cycle_year: RecruitmentCycle.current_recruitment_cycle.year,
        provider_code: course.provider.provider_code,
        code: course.course_code,
      }
    end
  end
end
