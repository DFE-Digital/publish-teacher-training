require "rails_helper"

module NotificationService
  describe CourseSubjectsUpdated do
    describe "#call" do
      let(:accredited_body) { create(:provider, :accredited_body) }
      let(:other_accredited_body) { create(:provider, :accredited_body) }
      let(:course) { create(:course, accredited_body_code: accredited_body.provider_code) }
      let(:previous_subject_names) {['primary with english']}
      let(:updated_subject_names) {['primary with mathematics']}
      let(:previous_course_name) { previous_subject_names.first }
      let(:updated_course_name) { updated_subject_names.first }

      let(:subscribed_user) { create(:user) }
      let(:non_subscribed_user) { create(:user) }
      let(:user_subscribed_to_other_provider) { create(:user) }

      let(:subscribed_notification) do
        create(
          :user_notification,
          user: subscribed_user,
          course_update: true,
          provider_code: accredited_body.provider_code,
        )
      end

      let(:non_subscribed_notification) do
        create(
          :user_notification,
          user: non_subscribed_user,
          course_update: false,
          provider_code: accredited_body.provider_code,
        )
      end

      let(:other_provider_notification) do
        create(
          :user_notification,
          user: user_subscribed_to_other_provider,
          course_publish: true,
          provider_code: other_accredited_body.provider_code,
        )
      end
      let(:self_accredited) { false }
      let(:findable) { true }

      def setup_notifications
        allow(CourseSubjectsUpdatedEmailMailer).to receive(:course_subjects_updated_email).and_return(double(deliver_later: true))
        subscribed_notification
        non_subscribed_notification
        other_provider_notification
        allow(course).to receive(:self_accredited?).and_return(self_accredited)
        allow(course).to receive(:findable?).and_return(findable)
      end

      def call_service
        described_class.call(
          course: course,
          previous_subject_names: previous_subject_names,
          previous_course_name: previous_course_name,
          )
      end

      before { setup_notifications }

      context "with a course that is in the current cycle" do
        it "sends notifications" do
          expect(CourseSubjectsUpdatedEmailMailer).to receive(:course_subjects_updated_email)
          expect(course.recruitment_cycle).to eql(RecruitmentCycle.current)

          call_service
        end
      end

      context "with a course that is not in the current cycle" do
        let(:provider) { create(:provider, :next_recruitment_cycle) }
        let(:course) { create(:course, accredited_body_code: accredited_body.provider_code, provider: provider) }

        it "does not send a notification" do
          expect(CourseSubjectsUpdatedEmailMailer).to_not receive(:course_subjects_updated_email)
          expect(course.recruitment_cycle).to_not eql(RecruitmentCycle.current)

          call_service
        end
      end

      context "non self-accredited course" do
        context "that is findable" do
          it "mails subscribed users" do
            expect(CourseSubjectsUpdatedEmailMailer)
              .to receive(:course_subjects_updated_email)
              .with(
              course: course,
              previous_subject_names: previous_subject_names,
              previous_course_name: previous_course_name,
              recipient: subscribed_user,).and_return(mailer = double)
            expect(mailer).to receive(:deliver_later).with(queue: "mailer")

            call_service
          end

          it "does not email non subscribed users" do
            expect(CourseSubjectsUpdatedEmailMailer).not_to receive(:course_subjects_updated_email)
              .with(course, non_subscribed_user)
            expect(CourseSubjectsUpdatedEmailMailer).not_to receive(:course_subjects_updated_email)
              .with(course, user_subscribed_to_other_provider)

            call_service
          end
        end

        context "that is not findable?" do
          let(:findable) { false }

          it "does not mail subscribed users" do
            expect(CourseSubjectsUpdatedEmailMailer)
              .not_to receive(:course_subjects_updated_email)

            call_service
          end
        end
      end

      context "self accredited course" do
        let(:self_accredited) { true }

        before { setup_notifications }

        it "does not mail subscribed users" do
          expect(CourseSubjectsUpdatedEmailMailer)
            .not_to receive(:course_subjects_updated_email)

          call_service
        end
      end
    end
  end
end
