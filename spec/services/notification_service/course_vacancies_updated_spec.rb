require "rails_helper"

module NotificationService
  describe CourseVacanciesUpdated do
    let(:subscribed_user1) { create(:user) }
    let(:subscribed_user2) { create(:user) }
    let(:non_subscribed_user) { create(:user) }
    let(:accredited_body) { create(:provider, :accredited_body) }

    let(:user_notifications) do
      create(:user_notification, user: subscribed_user1, provider: accredited_body, course_publish: true)
      create(:user_notification, user: subscribed_user2, provider: accredited_body, course_publish: true)
      create(:user_notification, user: non_subscribed_user, provider: accredited_body, course_publish: false)
    end

    let(:course) { create(:course, accrediting_provider: accredited_body) }
    let(:vacancy_statuses) do
      [
        { id: 123456, status: "no_vacancies" },
      ]
    end

    let(:service_call) { described_class.call(course: course, vacancy_statuses: vacancy_statuses) }

    def setup_notifications
      allow(CourseVacancies::UpdatedMailer).to receive(:fully_updated).and_return(double(deliver_later: true))
      user_notifications
    end

    context "with a course that is in the current cycle" do
      before { setup_notifications }

      it "sends notifications" do
        expect(CourseVacancies::UpdatedMailer).to receive(:fully_updated)
        expect(course.recruitment_cycle).to eql(RecruitmentCycle.current)

        service_call
      end
    end

    context "with a course that is not in the current cycle" do
      let(:provider) { create(:provider, :next_recruitment_cycle) }
      let(:course) { create(:course, accredited_body_code: accredited_body.provider_code, provider: provider) }

      before { setup_notifications }

      it "does not send notifications" do
        expect(CourseVacancies::UpdatedMailer).to_not receive(:fully_updated)
        expect(course.recruitment_cycle).to_not eql(RecruitmentCycle.current)

        service_call
      end
    end

    context "course is not self accredited" do
      before do
        setup_notifications
        allow(course).to receive(:self_accredited?).and_return(false)
      end

      it "sends notifications to users who have elected to receive notifications" do
        [subscribed_user1, subscribed_user2].each do |user|
          expect(CourseVacancies::UpdatedMailer)
            .to receive(:fully_updated)
                  .with(
                    course: course,
                    user: user,
                    datetime: DateTime.now,
                    vacancies_filled: true,
                  ).and_return(mailer = double)
          expect(mailer).to receive(:deliver_later)
        end

        service_call
      end
    end

    context "course is self accredited" do
      before do
        setup_notifications
        allow(course).to receive(:self_accredited?).and_return(true)
      end

      it "does not send a notification" do
        expect(CourseVacancies::UpdatedMailer).not_to receive(:fully_updated)

        service_call
      end
    end

    context "course with multiple locations" do
      before do
        setup_notifications
        allow(course).to receive(:self_accredited?).and_return(false)
      end

      context "all locations have no vacancies" do
        let(:vacancy_statuses) do
          [
            { id: 123456, status: "no_vacancies" },
            { id: 789789, status: "no_vacancies" },
          ]
        end

        it "sends a notification" do
          [subscribed_user1, subscribed_user2].each do |user|
            expect(CourseVacancies::UpdatedMailer)
              .to receive(:fully_updated)
                    .with({
                            course: course,
                            user: user,
                            datetime: DateTime.now,
                            vacancies_filled: true,
                          })
          end

          service_call
        end
      end

      context "all locations have vacancies" do
        let(:vacancy_statuses) do
          [
            { id: 123456, status: "full_time_vacancies" },
            { id: 789789, status: "part_time_vacancies" },
          ]
        end

        it "sends a notification" do
          [subscribed_user1, subscribed_user2].each do |user|
            expect(CourseVacancies::UpdatedMailer)
              .to receive(:fully_updated)
                    .with({
                            course: course,
                            user: user,
                            datetime: DateTime.now,
                            vacancies_filled: false,
                          })
          end

          service_call
        end
      end

      context "some locations have vacancies" do
        let(:first_site_status_id) { 123456 }
        let(:second_site_status_id) { 789789 }
        let(:first_site_status) { create(:site_status, id: first_site_status_id) }
        let(:second_site_status) { create(:site_status, id: second_site_status_id) }
        let(:vacancy_statuses) do
          [
            { id: first_site_status_id, status: "no_vacancies" },
            { id: second_site_status_id, status: "part_time_vacancies" },
          ]
        end
        let(:course) { create(:course, accrediting_provider: accredited_body, site_statuses: [first_site_status, second_site_status]) }

        before do
          first_site_status
          second_site_status
        end

        it "sends a notification" do
          [subscribed_user1, subscribed_user2].each do |user|
            expect(CourseVacancies::UpdatedMailer)
              .to receive(:partially_updated)
                    .with({
                            course: course,
                            user: user,
                            datetime: DateTime.now,
                            vacancies_closed: [first_site_status.site.location_name],
                            vacancies_opened: [second_site_status.site.location_name],
                          })
                    .and_return(double(deliver_later: true))
          end

          service_call
        end
      end
    end
  end
end
