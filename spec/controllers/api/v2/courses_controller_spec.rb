require "rails_helper"

describe API::V2::CoursesController, type: :controller do
  let(:site_status) { build(:site_status, :new) }
  let(:dfe_subject) { find_or_create(:primary_subject, :primary) }
  let(:provider) { create(:provider) }
  let(:accredited_body) { create(:provider, :accredited_body) }
  let(:course) do
    create(:course,
           :with_gcse_equivalency,
           site_statuses: [site_status],
           enrichments: [enrichment],
           subjects: [dfe_subject],
           provider: provider,
           accredited_body_code: accredited_body.provider_code)
  end
  let(:email) { "manage_courses@digital.education.gov.uk" }
  let(:sign_in_user_id) { "manage_courses_api" }
  let(:existing_user) { create(:user, admin: true, email: email, sign_in_user_id: sign_in_user_id) }

  before do
    allow(NotificationService::CoursePublished).to receive(:call).with(course: course)
    allow(controller).to receive(:authenticate).and_return(true)
    controller.instance_variable_set(:@current_user, existing_user)

    post :publish, params: {
      recruitment_cycle_year: provider.recruitment_cycle.year,
      provider_code: course.provider.provider_code,
      code: course.course_code,
    }
  end

  describe "#publish" do
    let(:enrichment) { build(:course_enrichment, :initial_draft) }

    let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: RecruitmentCycle.current.year) }

    it "sends the course publish notification" do
      expect(NotificationService::CoursePublished).to have_received(:call).with(course: course)
    end

    context "all the necessary course information has been submitted" do
      let(:provider) { create(:provider, recruitment_cycle: recruitment_cycle) }

      it "sends a notification that the course was published" do
        expect(NotificationService::CoursePublished).to have_received(:call).with(course: course)
      end
    end

    context "missing information on visa sponsorship, UKPRN and/or URN" do
      let(:provider_type) { :scitt }
      let(:validation_errors) { JSON(response.body, symbolize_names: true)[:errors].map { |e| e[:detail] } }
      let(:site) { create(:site, urn: nil) }
      let(:site_status) { create(:site_status, :running, site: site) }
      let(:provider) do
        create(:provider,
               provider_type: provider_type,
               can_sponsor_student_visa: nil,
               ukprn: nil,
               urn: nil,
               recruitment_cycle: recruitment_cycle)
      end

      it "doesn't send a notification" do
        expect(NotificationService::CoursePublished).not_to have_received(:call).with(course: course)
      end

      context "API response" do
        it "returns a 422 error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "has a validation error about provider not having visa sponsorship information" do
          expect(validation_errors).to include("Select if visas can be sponsored")
        end

        it "has a validation error about provider not having a UKPRN" do
          expect(validation_errors).to include("Enter a UK Provider Reference Number (UKPRN)")
        end

        context "provider is a lead school" do
          let(:provider_type) { :lead_school }

          it "has a validation error about provider not having a UKPRN and URN" do
            expect(validation_errors).to include("Enter a UK Provider Reference Number (UKPRN) and URN")
          end

          context "when only URN is nil" do
            let(:provider) do
              create(:provider,
                     provider_type: provider_type,
                     can_sponsor_student_visa: nil,
                     urn: nil,
                     recruitment_cycle: recruitment_cycle)
            end

            it "has a validation error about provider not having a UKPRN and URN" do
              expect(validation_errors).to include("Enter a UK Provider Reference Number (UKPRN) and URN")
            end
          end
        end
      end
    end
  end

  describe "#update_subjects" do
    let(:enrichment) { build(:course_enrichment, :initial_draft) }
    let(:previous_subject) { create(:primary_subject, :primary_with_english) }
    let(:updated_subject) { create(:primary_subject, :primary_with_mathematics) }
    let(:previous_course_name) { "Primary with English" }
    let(:updated_course_name) { "Primary with mathematics" }
    let(:course) {
      create(:course,
             name: previous_course_name,
             site_statuses: [site_status],
             enrichments: [enrichment],
             subjects: [previous_subject])
    }
    let(:updated_course) { create(:course, subjects: [updated_subject]) }

    it "sends the subjects updated notification" do
      expect(NotificationService::CourseSubjectsUpdated)
        .to receive(:call)
              .with(
                course: an_instance_of(Course),
                previous_subject_names: ["Primary with English"],
                previous_course_name: previous_course_name,
              )
      post :update, params: {
        recruitment_cycle_year: RecruitmentCycle.current_recruitment_cycle.year,
        provider_code: course.provider.provider_code,
        code: course.course_code,
        course: { subjects_ids: [updated_subject.id] },
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

  describe "#send_vacancies_update_notification" do
    let(:enrichment) { build(:course_enrichment, :published) }
    let(:vacancy_statuses) {
      { id: "123456", status: "no_vacancies" }
    }

    it "sends the course vacancies updated notification" do
      expect(NotificationService::CourseVacanciesUpdated)
        .to receive(:call)
        .with(
          course: course,
          vacancy_statuses: [ActionController::Parameters.new(vacancy_statuses).permit!],
        )

      post :send_vacancies_updated_notification, params: {
        recruitment_cycle_year: RecruitmentCycle.current_recruitment_cycle.year,
        provider_code: course.provider.provider_code,
        code: course.course_code,
        _jsonapi: {
          vacancy_statuses: [vacancy_statuses],
        },
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

        expect(course.reload.name).not_to eql("new course name")
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
