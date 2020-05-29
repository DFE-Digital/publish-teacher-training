require "rails_helper"

describe Courses::UpdateNotificationService do
  let(:organisation) { create :organisation }
  let(:user1) { create :user, organisations: [organisation] }
  let(:user2) { create :user, organisations: [organisation] }
  let(:user3) { create :user, organisations: [organisation] }
  let(:user_notifications) do
    create(:user_notification, user: user1, provider: provider, course_update: true)
    create(:user_notification, user: user2, provider: provider, course_update: true)
    create(:user_notification, user: user3, provider: provider, course_update: false)
  end
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:mail_spy) { spy }
  let(:mailer_spy) { spy(course_update_email: mail_spy) }
  let(:course) do
    create(
      :course,
      age_range_in_years: "3_to_7",
      accrediting_provider: provider,
    )
  end
  let(:findable) { build(:site_status, :findable) }
  let(:new) { build(:site_status, :new) }
  let(:service_call) { described_class.new.call(course: course) }

  before do
    stub_const("CourseUpdateEmailMailer", mailer_spy)
    user_notifications
  end

  context "course is findable" do
    let(:course) do
      create(
        :course,
        age_range_in_years: "3_to_7",
        site_statuses: [findable],
        accrediting_provider: provider,
      )
    end

    context "provider is not self accredited" do
      let(:provider) do
        create(:provider,
               organisations: [organisation],
               recruitment_cycle: recruitment_cycle)
      end

      it "sends notifications to users who have elected to recieve notifications" do
        course.age_range_in_years = "7_to_14"
        course.save
        service_call

        expect(mailer_spy).to have_received(:course_update_email).twice
        expect(mailer_spy).to have_received(:course_update_email).with(
          course: course,
          attribute_name: "age_range_in_years",
          original_value: "3_to_7",
          updated_value: "7_to_14",
          recipient: user1,
        )
        expect(mailer_spy).to have_received(:course_update_email).with(
          course: course,
          attribute_name: "age_range_in_years",
          original_value: "3_to_7",
          updated_value: "7_to_14",
          recipient: user2,
        )
      end
    end

    context "provider is self accredited" do
      let(:provider) do
        create(:provider,
               :accredited_body,
               organisations: [organisation],
               recruitment_cycle: recruitment_cycle)
      end

      let(:course) do
        create(
          :course,
          age_range_in_years: "3_to_7",
          provider: provider,
        )
      end

      it "does not send a notification" do
        service_call
        expect(mailer_spy).not_to have_received(:course_update_email)
      end
    end
  end

  context "course is not findable" do
    let(:course) do
      create(
        :course,
        age_range_in_years: "3_to_7",
        site_statuses: [new],
        provider: provider,
      )
    end

    let(:provider) do
      create(:provider,
             :accredited_body,
             organisations: [organisation],
             recruitment_cycle: recruitment_cycle)
    end

    it "does not send a notification" do
      service_call
      expect(mailer_spy).not_to have_received(:course_update_email)
    end
  end
end
