require "rails_helper"

describe API::V2::SiteStatusesController, type: :controller do
  let(:site_status) { build(:site_status, :running) }
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

  describe "#update" do
    let(:enrichment) { build(:course_enrichment, :published) }

    it "sends the course vacancies full notification" do
      expect(NotificationService::CourseVacanciesFilled).to receive(:call).with(course: course)
      post :update, params: {
        id: site_status.id,
        site_status: {
          vac_status: "no_vacancies",
        },
      }
    end
  end
end
