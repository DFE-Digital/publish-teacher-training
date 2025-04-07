# frozen_string_literal: true

require "rails_helper"

module NotificationService
  describe CourseWithdrawn do
    let(:subscribed_user1) { create(:user) }
    let(:subscribed_user2) { create(:user) }
    let(:non_subscribed_user) { create(:user) }
    let(:accredited_provider) { create(:provider, :accredited_provider) }

    let(:course) { create(:course, accrediting_provider: accredited_provider) }

    subject(:service_call) { described_class.call(course:) }

    before do
      create(:user_notification, user: subscribed_user1, provider: accredited_provider, course_publish: true)
      create(:user_notification, user: subscribed_user2, provider: accredited_provider, course_publish: true)
      create(:user_notification, user: non_subscribed_user, provider: accredited_provider, course_publish: false)
    end

    context "with a course that is in the current cycle" do
      it "sends notifications", :freeze do
        expect(course.recruitment_cycle).to eql(RecruitmentCycle.current)

        expect { service_call }.to have_enqueued_mail(CourseWithdrawEmailMailer, :course_withdraw_email).with(course, subscribed_user1, Time.current)
          .and have_enqueued_mail(CourseWithdrawEmailMailer, :course_withdraw_email).with(course, subscribed_user2, Time.current)
      end
    end

    context "with a course that is not in the current cycle" do
      let(:provider) { create(:provider, :next_recruitment_cycle) }
      let(:course) { create(:course, accredited_provider_code: accredited_provider.provider_code, provider:) }

      it "does not send notifications" do
        expect(course.recruitment_cycle).not_to eql(RecruitmentCycle.current)

        expect { service_call }.to not_have_enqueued_mail(CourseWithdrawEmailMailer, :course_withdraw_email)
      end
    end

    context "course is not self accredited" do
      before do
        allow(course).to receive(:self_accredited?).and_return(false)
      end

      it "sends notifications to users who have elected to recieve notifications", :freeze do
        expect { service_call }.to have_enqueued_mail(CourseWithdrawEmailMailer, :course_withdraw_email).with(course, subscribed_user1, Time.current)
          .and have_enqueued_mail(CourseWithdrawEmailMailer, :course_withdraw_email).with(course, subscribed_user2, Time.current)
      end
    end

    context "course is self accredited" do
      before do
        allow(course).to receive(:self_accredited?).and_return(true)
      end

      it "does not send a notification" do
        expect { service_call }.to not_have_enqueued_mail(CourseWithdrawEmailMailer, :course_withdraw_email)
      end
    end
  end
end
