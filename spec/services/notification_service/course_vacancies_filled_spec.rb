require "rails_helper"

module NotificationService
  describe CourseVacanciesFilled do
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

    let(:service_call) { described_class.call(course: course) }

    def setup_notifications
      allow(CourseVacanciesFilledEmailMailer).to receive(:course_vacancies_filled_email).and_return(double(deliver_later: true))
      user_notifications
    end

    context "with a course that is in the current cycle" do
      before { setup_notifications }

      it "sends notifications" do
        expect(CourseVacanciesFilledEmailMailer).to receive(:course_vacancies_filled_email)
        expect(course.recruitment_cycle).to eql(RecruitmentCycle.current)
        described_class.call(course: course)
      end
    end

    context "with a course that is not in the current cycle" do
      let(:provider) { create(:provider, :next_recruitment_cycle) }
      let(:course) { create(:course, accredited_body_code: accredited_body.provider_code, provider: provider) }

      before { setup_notifications }

      it "does not notifications" do
        expect(CourseVacanciesFilledEmailMailer).to_not receive(:course_vacancies_filled_email)
        expect(course.recruitment_cycle).to_not eql(RecruitmentCycle.current)
        described_class.call(course: course)
      end
    end

    context "course is not self accredited" do
      before do
        setup_notifications
        allow(course).to receive(:self_accredited?).and_return(false)
      end

      it "sends notifications to users who have elected to recieve notifications" do
        [subscribed_user1, subscribed_user2].each do |user|
          expect(CourseVacanciesFilledEmailMailer)
            .to receive(:course_vacancies_filled_email)
                  .with(
                    course,
                    user,
                    DateTime.now,
                  ).and_return(mailer = double)
          expect(mailer).to receive(:deliver_later).with(queue: "mailer")
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
        expect(CourseVacanciesFilledEmailMailer).not_to receive(:course_vacancies_filled_email)
        service_call
      end
    end
  end
end
