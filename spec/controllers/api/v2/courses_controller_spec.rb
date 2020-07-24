require "rails_helper"

describe API::V2::CoursesController, type: :controller do
  let(:site_status) { build(:site_status, :new) }
  let(:dfe_subject) { find_or_create(:primary_subject, :primary) }
  let(:course) {
    create(:course,
           site_statuses: [site_status],
           enrichments: [enrichment],
           subjects: [dfe_subject])
  }
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

  describe "#publish" do
    let(:enrichment) { build(:course_enrichment, :initial_draft) }

    it "sends the course publish notification" do
      expect(NotificationService::CoursePublished).to receive(:call).with(course: course)
      post :publish, params: {
        recruitment_cycle_year: RecruitmentCycle.current_recruitment_cycle.year,
        provider_code: course.provider.provider_code,
        code: course.course_code,
      }
    end
  end

  describe "#withdraw" do
    let(:enrichment) { build(:course_enrichment, :published) }

    it "sends the course withdrawn notification" do
      expect(NotificationService::CourseWithdrawn).to receive(:call).with(course: course)
      post :withdraw, params: {
        recruitment_cycle_year: RecruitmentCycle.current_recruitment_cycle.year,
        provider_code: course.provider.provider_code,
        code: course.course_code,
      }
    end
  end

  describe "#send_vacancies_filled_notification" do
    let(:enrichment) { build(:course_enrichment, :published) }

    it "sends the course vacancies full notification" do
      expect(NotificationService::CourseVacanciesFilled).to receive(:call).with(course: course)
      post :send_vacancies_filled_notification, params: {
        recruitment_cycle_year: RecruitmentCycle.current_recruitment_cycle.year,
        provider_code: course.provider.provider_code,
        code: course.course_code,
      }
    end
  end

  describe "#update" do
    let(:enrichment) { build(:course_enrichment, :published) }

    context "as non-admin" do
      let(:existing_user) { course.provider.users.first }

      it "cannot update admin fields" do
        expect {
          put :update, params: {
            recruitment_cycle_year: RecruitmentCycle.current_recruitment_cycle.year,
            provider_code: course.provider.provider_code,
            code: course.course_code,
            course: { name: "new course name" },
          }
        }.to raise_error(ActionController::UnpermittedParameters)

        expect(course.reload.name).to_not eql("new course name")
      end
    end

    context "as admin" do
      it "can update admin fields" do
        put :update, params: {
          recruitment_cycle_year: RecruitmentCycle.current_recruitment_cycle.year,
          provider_code: course.provider.provider_code,
          code: course.course_code,
          course: { name: "new course name" },
        }

        expect(course.reload.name).to eql("new course name")
      end
    end

    context "updating sites" do
      let(:site1) { create(:site, location_name: "location 1") }
      let(:site2) { create(:site, location_name: "location 2") }
      let(:site_status) { create(:site_status, :running, site: site1) }
      let(:provider) { create(:provider, sites: [site1, site2]) }
      let(:course) { create(:course, provider: provider, site_statuses: [site_status]) }

      it "sends the course update sites notification" do
        expect(NotificationService::CourseSitesUpdated).to receive(:call).with(
          course: course,
          previous_site_names: [site1.location_name],
          updated_site_names: [site2.location_name],
        )

        put :update, params: {
          recruitment_cycle_year: RecruitmentCycle.current_recruitment_cycle.year,
          provider_code: course.provider.provider_code,
          code: course.course_code,
          course: { sites_ids: [site2.id] },
        }
      end
    end
  end
end
