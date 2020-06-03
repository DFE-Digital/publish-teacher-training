require "rails_helper"

module NotificationService
  describe CourseUpdated do
    let(:subscribed_user1) { create(:user) }
    let(:subscribed_user2) { create(:user) }
    let(:non_subscribed_user) { create(:user) }
    let(:accredited_body) { create(:provider, :accredited_body) }

    let(:user_notifications) do
      create(:user_notification, user: subscribed_user1, provider: accredited_body, course_update: true)
      create(:user_notification, user: subscribed_user2, provider: accredited_body, course_update: true)
      create(:user_notification, user: non_subscribed_user, provider: accredited_body, course_update: false)
    end

    let(:course) do
      create(
        :course,
        age_range_in_years: "3_to_7",
        accrediting_provider: accredited_body,
      )
    end

    let(:service_call) { described_class.call(course: course) }

    before do
      allow(CourseUpdateEmailMailer).to receive(:course_update_email)
      user_notifications
    end

    context "course is findable" do
      before { allow(course).to receive(:findable?).and_return(true) }

      context "course is not self accredited" do
        before { allow(course).to receive(:self_accredited?).and_return(false) }

        it "sends notifications to users who have elected to recieve notifications" do
          [subscribed_user1, subscribed_user2].each do |user|
            expect(CourseUpdateEmailMailer)
              .to receive(:course_update_email)
              .with(
                course: course,
                attribute_name: "age_range_in_years",
                original_value: "3_to_7",
                updated_value: "7_to_14",
                recipient: user,
              ).and_return(mailer = double)
            expect(mailer).to receive(:deliver_later).with(queue: "mailer")
          end

          course.age_range_in_years = "7_to_14"
          course.save
          service_call
        end
      end

      context "course is self accredited" do
        before { allow(course).to receive(:self_accredited?).and_return(true) }

        it "does not send a notification" do
          expect(CourseUpdateEmailMailer).not_to receive(:course_update_email)
          service_call
        end
      end
    end

    context "course is not findable" do
      before { allow(course).to receive(:findable?).and_return(false) }

      it "does not send a notification" do
        expect(CourseUpdateEmailMailer).not_to receive(:course_update_email)
        service_call
      end
    end
  end
end
